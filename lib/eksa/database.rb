require 'json'
begin
  require 'dotenv'
  Dotenv.load if File.exist?('.env')
rescue LoadError
  # Dotenv not available, rely on existing ENV
end

module Eksa
  module Database
    def self.adapter
      @adapter ||= create_adapter
    end

    def self.reset_adapter
      @adapter = nil
    end

    def self.create_adapter
      config = load_config
      type = config.dig('database', 'type') || 'sqlite'

      case type
      when 'mongo', 'mongodb'
        require_relative 'database/mongo_adapter'
        mongo_config = config.dig('database', 'mongodb') || {}
        
        # Prioritize Environment Variable for Security
        env_uri = ENV['EKSA_MONGODB_URI'] || ENV['MONGODB_URI']
        mongo_config['uri'] = env_uri if env_uri

        MongoAdapter.new(mongo_config)
      else
        require_relative 'database/sqlite_adapter'
        SqliteAdapter.new(config.dig('database', 'sqlite'))
      end
    end

    def self.load_config
      config_path = File.join(Dir.pwd, '.eksa.json')
      return {} unless File.exist?(config_path)
      JSON.parse(File.read(config_path))
    rescue
      {}
    end
  end
end
