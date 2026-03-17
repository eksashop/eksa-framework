require_relative '../lib/eksa'

db = Eksa::Database.adapter

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS pesan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    konten TEXT,
    pengirim TEXT
  );
SQL

puts "✅ Database Eksa berhasil disiapkan (Engine: #{Eksa::Database.adapter.class})!"