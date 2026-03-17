# ✨ Eksa Framework v3.5.2

[![Ruby Version](https://img.shields.io/badge/ruby-3.0+-red.svg)](https://www.ruby-lang.org/)
[![Rack Version](https://img.shields.io/badge/rack-3.0+-blue.svg)](https://rack.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Framework Role](https://img.shields.io/badge/UI-Glassmorphism-indigo.svg)](#)

**Eksa Framework** adalah *micro-framework* MVC (Model-View-Controller) modern yang dibangun di atas Ruby dan Rack. Didesain untuk pengembang yang menginginkan kecepatan, kode yang bersih, dan tampilan antarmuka **Glassmorphism** yang elegan secara *out-of-the-box*.

---

## 🚀 Fitur Unggulan v3.5.2

* 💎 **Modern Glassmorphism UI**: Tampilan transparan yang indah dengan Tailwind CSS & Lucide Icons.
* 📱 **Mobile Responsive Navigation**: Sistem navigasi adaptif dengan mobile drawer yang elegan.
* ⚡ **Rack 3 & Middleware Support**: Mendukung standar terbaru dan pembuatan pipeline middleware kustom.
* 🛠️ **Powerful CLI**: Inisialisasi project (`eksa init`), jalankan server (`eksa run`), generate komponen, ganti database, dan **migrasi data** otomatis.
* 💾 **Agnostic Database Engine**: Dukungan multi-database (**SQLite** & **MongoDB Atlas**) dengan sistem adapter yang otomatis dan transparan.
* 🛡️ **Secure Environment Variables**: Dukungan file `.env` untuk menyimpan kredensial database (MongoDB URI) secara aman.
* ⚙️ **JIT Schema Initialization**: Inisialisasi tabel/koleksi secara otomatis tepat saat model pertama kali diakses.
* 🧪 **Built-in Testing**: Lingkungan pengujian otomatis siap pakai menggunakan RSpec dan `rack-test`.
* 🛡️ **Built-in Authentication**: Sistem keamanan BCrypt dengan proteksi sesi Rack untuk registrasi log-in area Admin.
* 📝 **Interactive CMS Dashboard**: Panel admin integratif untuk mengedit isi blog Markdown & transisi visibilitas via UI.
* 🔍 **Dynamic SEO Engine**: Penanganan otomatis file `robots.txt`, `sitemap.xml`, dan dukungan **JSON-LD** (Structured Data).
* 🎨 **Asset Helpers**: Library bawaan untuk pengelolaan CSS dan JS yang lebih rapi.
* 👻 **Aesthetic Error Pages**: Halaman 404 dengan desain Glassmorphism yang elegan secara native.

---

## 🛠️ Instalasi Cepat

### 1. Install via Gem
```bash
gem install eksa-framework
```

### 2. Inisialisasi Project Baru
```bash
mkdir my-app && cd my-app
eksa init
```

### 3. Konfigurasi Keamanan (Opsi MongoDB)
Salin `.env.example` menjadi `.env` dan isi kredensial Anda:
```bash
cp .env.example .env
```

### 4. Jalankan Server
```bash
bundle install
eksa run
```

---

## 💻 Panduan Pengembangan

### 1. CLI Generator & Utility
Hemat waktu dengan menggunakan generator bawaan:

```bash
# Membuat controller dan view template
eksa g controller Berita

# Membuat model (Schema akan dibuat otomatis saat diakses)
eksa g model Artikel

# Membuat postingan blog baru dengan meta tambahan
eksa g post "Panduan Eksa" --category "Tutorial" --author "Eksa Team" --image "url-gambar.jpg"

# Mengaktifkan/menonaktifkan fitur (auth / cms)
eksa feature enable auth
eksa feature enable cms

# Manajemen Database (Switch & Migrate)
eksa db switch mongo                             # Pindah ke MongoDB
eksa db migrate --from sqlite --to mongo         # Pindah data ke Cloud

# Reset Password Admin
eksa reset-password admin PasswordRahasia123
```

### 2. Database & Model (Agnostic)
Definisikan schema tabel Anda di dalam model. Eksa akan menanganinya secara cerdas baik di SQLite maupun MongoDB:

```ruby
class Artikel < Eksa::Model
  def self.setup_schema
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS artikels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT,
        konten TEXT,
        penulis TEXT
      )
    SQL
  end
  
  def self.semua
    db.execute("SELECT * FROM artikels ORDER BY id DESC")
  end
end
```

### 3. CMS Dashboard & Blog Engine
Eksa memiliki sistem blog bawaan yang cara kerjaja mirip Jekyll namun dengan kemudahan CMS.

- **Blog Markdown**: Simpan file `.md` di `_posts/` dengan Front Matter YAML.
- **Dynamic Routing**: Otomatis mengenali rute `/posts/:slug`.
- **Admin Panel**: Akses `/cms` untuk mengedit konten menggunakan editor terintegrasi, ganti status (*Draft/Published*), atau hapus postingan.

### 4. SEO & Metadata
Eksa secara otomatis menghasilkan:
- `http://localhost:9292/sitemap.xml`
- `http://localhost:9292/robots.txt`
- **JSON-LD**: Skema `BlogPosting` dan `WebSite` disematkan otomatis pada layout untuk peringkat SEO yang lebih baik.

### 5. Menjalankan Test
Gunakan RSpec yang sudah terkonfigurasi untuk memastikan aplikasi stabil:

```bash
bundle exec rspec
```

---

## 🤝 Kontribusi & Komunitas

Kami sangat terbuka untuk kontribusi dari siapa pun! Silakan baca panduan berikut sebelum memulai:

- **[Panduan Kontribusi](CONTRIBUTING.md)**: Langkah-langkah untuk berkontribusi kode.
- **[Kebijakan Keamanan](SECURITY.md)**: Cara melaporkan kerentanan secara privat.
- **[Kode Etik](CODE_OF_CONDUCT.md)**: Standar perilaku dalam komunitas kami.

---

## 📜 Lisensi
Proyek ini dilisensikan di bawah **MIT License**. Lihat file [LICENSE](LICENSE) untuk detail lebih lanjut.