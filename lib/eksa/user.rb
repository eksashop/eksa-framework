module Eksa
  class User < Eksa::Model
    require 'bcrypt'

    def self.setup_schema
      db.execute <<~SQL
        CREATE TABLE IF NOT EXISTS eksa_users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password_hash TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      SQL
    end

    def self.all
      db.execute("SELECT id, username FROM eksa_users")
    end

    def self.create(username, password)
      hash = BCrypt::Password.create(password)
      db.execute("INSERT INTO eksa_users (username, password_hash) VALUES (?, ?)", [username, hash])
    end

    def self.update_password(username, new_password)
      hash = BCrypt::Password.create(new_password)
      db.execute("UPDATE eksa_users SET password_hash = ? WHERE username = ?", [hash, username])
    end

    def self.authenticate(username, password)
      user_data = db.execute("SELECT id, username, password_hash FROM eksa_users WHERE username = ? LIMIT 1", [username]).first
      return nil unless user_data

      stored_hash = BCrypt::Password.new(user_data[2])
      if stored_hash == password
        { id: user_data[0], username: user_data[1] }
      else
        nil
      end
    end

    def self.find(id)
      user_data = db.execute("SELECT id, username FROM eksa_users WHERE id = ? LIMIT 1", [id]).first
      user_data ? { id: user_data[0], username: user_data[1] } : nil
    end
  end
end
