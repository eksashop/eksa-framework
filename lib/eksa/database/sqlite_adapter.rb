require 'sqlite3'
require 'fileutils'

module Eksa
  class SqliteAdapter
    def initialize(config)
      @path = config&.[]('path') || File.expand_path("../../../db/eksa_app.db", __FILE__)
      ensure_db_dir
    end

    def connection
      @connection ||= SQLite3::Database.new(@path)
    end

    def execute(sql, params = [])
      connection.execute(sql, params)
    end

    private

    def ensure_db_dir
      db_dir = File.dirname(@path)
      FileUtils.mkdir_p(db_dir) unless Dir.exist?(db_dir)
    end
  end
end
