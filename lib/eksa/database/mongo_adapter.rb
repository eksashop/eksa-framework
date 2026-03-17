require 'mongo'

module Eksa
  class MongoAdapter
    def initialize(config)
      @uri = config&.[]('uri')
      @client = nil
    end

    def connection
      return @client if @client
      raise "MongoDB URI not configured in .eksa.json" if @uri.nil? || @uri.empty?
      
      # Atlas URIs usually contain the database name, if not, we use 'eksa_db'
      @client = Mongo::Client.new(@uri)
      @client
    end

    def execute(sql, params = [])
      # Minimal SQL-to-Mongo translator for Eksa models
      
      # 1. CREATE TABLE IF NOT EXISTS [table]
      if sql =~ /CREATE TABLE IF NOT EXISTS (\w+)/i
        # Mongo creates collections on the fly
        return []
      end

      # 2. SELECT * FROM [table] ...
      if sql =~ /SELECT (.*) FROM (\w+)/i
        table_name = $2
        query = {}
        
        # Handle WHERE clauses
        if sql =~ /WHERE (.*) ORDER BY/i || sql =~ /WHERE (.*) LIMIT/i || sql =~ /WHERE (.*)$/i
          where_clause = $1
          
          # Handle OR + LIKE (specific for Search)
          if where_clause =~ /(\w+) LIKE \? OR (\w+) LIKE \?/i
            field1 = $1
            field2 = $2
            # Extract keyword from params (strip % if present)
            term1 = params[0].to_s.gsub('%', '')
            term2 = params[1].to_s.gsub('%', '')
            
            query = {
              '$or' => [
                { field1.to_sym => /#{Regexp.escape(term1)}/i },
                { field2.to_sym => /#{Regexp.escape(term2)}/i }
              ]
            }
          # Handle single LIKE
          elsif where_clause =~ /(\w+) LIKE \?/i
            field = $1
            term = params[0].to_s.gsub('%', '')
            query = { field.to_sym => /#{Regexp.escape(term)}/i }
          # Handle simple field = ?
          elsif where_clause =~ /id = \?/i || where_clause =~ /_id = \?/i
            val = params[0]
            query = { _id: val.is_a?(String) ? BSON::ObjectId.from_string(val) : val }
          elsif where_clause =~ /(\w+) = \?/i
            query = { $1.to_sym => params[0] }
          end
        end

        view = connection[table_name.to_sym].find(query)
        
        # Handle ORDER BY
        if sql =~ /ORDER BY (\w+)(?: (ASC|DESC))?/i
          sort_field = $1
          direction = ($2 || 'ASC').upcase == 'DESC' ? -1 : 1
          # Mongo id maps to _id
          sort_field = '_id' if sort_field == 'id'
          view = view.sort({ sort_field => direction })
        end

        view = view.limit(1) if sql =~ /LIMIT 1/i
        results = view.to_a
        
        return results.map do |doc|
          # Try to make it look like a flat array similar to SQLite row
          # We don't know the exact schema, but we can return the values
          # For Eksa::User we specifically need [id, username, password_hash]
          if table_name == 'eksa_users'
            [doc['_id'].to_s, doc['username'], doc['password_hash'], doc['created_at']]
          else
            # For other models, return a hash-like object if possible, 
            # or just the values in order. Since User specifically uses indices, 
            # and generic models might use indices or keys, this is tricky.
            # Most Eksa models result in array-of-arrays from SQLite gem.
            doc.values.map { |v| v.is_a?(BSON::ObjectId) ? v.to_s : v }
          end
        end
      end

      # 3. INSERT INTO [table] ([cols]) VALUES ([vals])
      if sql =~ /INSERT INTO (\w+) \((.*)\) VALUES/i
        table_name = $1
        cols = $2.split(',').map(&:strip)
        doc = {}
        cols.each_with_index do |col, i|
          doc[col.to_sym] = params[i]
        end
        doc[:created_at] ||= Time.now
        
        connection[table_name.to_sym].insert_one(doc)
        return []
      end

      # 4. UPDATE [table] SET [col1] = ?, [col2] = ? WHERE [col] = ?
      if sql =~ /UPDATE (\w+) SET (.*) WHERE (\w+) = \?/i
        table_name = $1
        set_clause = $2
        where_col = $3
        
        # Parse set assignments (e.g., "col1 = ?, col2 = ?")
        # We assume the order matches params[0...n-1]
        cols = set_clause.split(',').map { |s| s.split('=').first.strip }
        
        set_data = {}
        cols.each_with_index do |col, i|
          set_data[col.to_sym] = params[i]
        end
        
        # The last parameter is the WHERE value
        where_val = params.last
        selector = if where_col == 'id'
          { _id: where_val.is_a?(String) ? BSON::ObjectId.from_string(where_val) : where_val }
        else
          { where_col.to_sym => where_val }
        end

        connection[table_name.to_sym].update_one(selector, { '$set' => set_data })
        return []
      end

      # 5. DELETE FROM [table] WHERE (\w+) = ?
      if sql =~ /DELETE FROM (\w+) WHERE (\w+) = \?/i
        table_name = $1
        where_col = $2
        
        selector = if where_col == 'id'
          { _id: params[0].is_a?(String) ? BSON::ObjectId.from_string(params[0]) : params[0] }
        else
          { where_col.to_sym => params[0] }
        end
        
        connection[table_name.to_sym].delete_one(selector)
        return []
      end

      raise "Unsupported SQL query for MongoAdapter: #{sql}"
    end
  end
end
