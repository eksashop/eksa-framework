require_relative 'database'

module Eksa
  class Model
    def self.db
      ensure_schema
      Eksa::Database.adapter
    end

    def self.ensure_schema
      return if @schema_initialized
      @schema_initialized = true
      setup_schema if respond_to?(:setup_schema)
    end
  end
end