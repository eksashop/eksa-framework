# Panduan Kontribusi Eksa Framework

Terima kasih telah tertarik untuk berkontribusi pada **Eksa Framework**! Kami sangat menghargai bantuan Anda untuk membuat micro-framework ini menjadi lebih baik, lebih cepat, dan lebih elegan.

---

## 🏔️ Filosofi Proyek
Eksa Framework didesain sebagai *micro-framework* MVC yang ringan namun kuat, dengan penekanan pada:
1.  **Kemudahan Penggunaan**: API yang intuitif untuk pengembang Ruby.
2.  **Keindahan Visual**: Antarmuka *Glassmorphism* yang modern secara bawaan.
3.  **Fleksibilitas**: Mendukung SQLite dan MongoDB Atlas secara transparan.

---

## 🚩 Cara Melaporkan Masalah (Bugs)
Jika Anda menemukan bug, silakan buat *Issue* di GitHub dengan informasi berikut:
- Penjelasan singkat tentang masalah.
- Langkah-langkah untuk mereproduksi bug.
- Hasil yang diharapkan vs hasil yang sebenarnya.
- Versi Ruby dan Eksa Framework yang digunakan.

---

## 💡 Mengusulkan Fitur Baru
Kami selalu terbuka untuk ide-ide baru! Untuk mengusulkan fitur:
1.  Buka *Issue* baru dan beri label `enhancement`.
2.  Jelaskan mengapa fitur tersebut berguna dan bagaimana cara kerjanya.
3.  Sertakan contoh penggunaan jika memungkinkan.

---

## 🛠️ Persiapan Pengembangan

### 1. Fork & Clone
*Fork* repositori ini ke akun GitHub Anda, lalu lakukan *clone* secara lokal:
```bash
git clone https://github.com/USERNAME/eksa_framework.git
cd eksa_framework
```

### 2. Instalasi Dependensi
Pastikan Anda memiliki Ruby (v3.0+) dan terinstal `bundler`.
```bash
bundle install
```

### 3. Membuat Branch
Selalu buat *branch* baru untuk setiap fitur atau perbaikan bug:
```bash
# Untuk fitur baru
git checkout -b feature/nama-fitur-anda

# Untuk perbaikan bug
git checkout -b bugfix/deskripsi-perbaikan
```

---

## 🎨 Standar Kode & Dokumentasi
- Ikuti [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide).
- Pastikan kode Anda bersih dan mudah dibaca.
- Tambahkan komentar jika logika kode cukup kompleks.
- Jika Anda menambahkan fitur baru, pastikan untuk memperbarui `README.md` atau dokumentasi terkait.

---

## 🧪 Pengujian (Testing)
Kami menggunakan **RSpec** untuk memastikan stabilitas framework. Sebelum mengirimkan *Pull Request*, pastikan semua test lulus:
```bash
bundle exec rspec
```
Sangat disarankan untuk menambahkan test baru jika Anda menambahkan fitur atau memperbaiki bug.

---

## 🚀 Proses Pull Request
1.  Pastikan kode Anda sudah di-test secara lokal.
2.  Kirimkan *Pull Request* (PR) ke *branch* `main` di repositori utama.
3.  Berikan deskripsi yang jelas tentang apa yang Anda rubah di dalam PR.
4.  Tim kami akan meninjau PR Anda sesegera mungkin.

---

## 🛡️ Keamanan
Keamanan adalah prioritas kami. Jika Anda menemukan kerentanan, harap baca [Kebijakan Keamanan](SECURITY.md) kami sebelum melaporkannya.

---

## 📜 Kode Etik
Harap bersikap sopan dan profesional dalam setiap interaksi di proyek ini. Kami ingin membangun komunitas yang inklusif dan ramah bagi semua pengembang. Dengan berpartisipasi, Anda diharapkan untuk mematuhi [Kode Etik](CODE_OF_CONDUCT.md) kami.

Terima kasih telah berkontribusi! 🚀
