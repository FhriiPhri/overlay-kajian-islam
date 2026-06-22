# Proyek Overlay & Live Controller Kajian Islami OBS (4K UHD)

Sistem manajemen grafis siaran langsung (*broadcast overlay*) berbasis web yang dirancang khusus untuk kebutuhan streaming kajian majelis ilmu atau siaran religi beresolusi **4K Ultra HD (3840 × 2160)**. Proyek ini memisahkan antara tampilan layar utama (*Overlay*) dan panel kendali operator (*Live Controller*) yang terhubung secara real-time menggunakan Node.js/Express backend API.

---

## ✦ Fitur Utama

* **Tampilan Siaran Beresolusi 4K (3840 × 2160):** Dioptimalkan untuk kejernihan teks maksimal pada kanvas OBS beresolusi tinggi dengan transparansi penuh.
* **Desain Elegan Islami & Premium:** Dilengkapi dengan aksen warna hijau zamrud (*emerald interior*), bingkai emas bergradasi bergerak (*gold border shine*), ornamen geometris di sudut layar, dan pola *watermark* halus.
* **Panel Kendali Mandiri (Live Controller):** Halaman kontrol yang intuitif bagi operator untuk memperbarui teks pembicara, judul kajian, menyertakan kutipan ayat/hadits, hingga mengatur *running text (ticker)* secara dinamis.
* **Perbaruan Real-Time Efisien:** Komunikasi overlay menggunakan teknik *polling data diffing* yang halus—menghindari kedipan visual (*flicker*) atau pemuatan ulang animasi *marquee* jika tidak ada perubahan teks yang signifikan.
* **Sistem Preset Manajemen Tema:** Menyimpan konfigurasi teks ke dalam penyimpanan lokal (*localStorage*) sehingga mempermudah operator mengganti profil pembicara dalam satu klik.

---

## 📁 Struktur Berkas Proyek

```text
├── index.html            # Tampilan Utama Overlay (Sumber Browser di OBS)
├── controller.html       # Dasbor Operator (Live Controller)
├── server.js             # Aplikasi Backend Node.js / Express API Server
├── start.bat             # Skrip Batch otomatis untuk menjalankan lokal server
└── assets/
    ├── style.css         # Variabel warna dasar, font, dan utilitas global
    ├── pattern.svg       # Pola geometris islami untuk latar belakang kartu
    └── logo.png          # Logo majelis / media kajian utama

```

---

## 🚀 Alur Kerja Sistem

Sistem ini memisahkan peran antara halaman penampil (`index.html`) dan pengendali (`controller.html`) menggunakan server lokal sebagai jembatan komunikasi datanya.

```text
+------------------------+              POST /api/state             +---------------------+
|    Live Controller     |  ------------------------------------->  |   Node.js Server    |
|   (controller.html)    |                                          |     (server.js)     |
+------------------------+                                          +---------------------+
                                                                               |
                                                                               | GET /api/state
                                                                               v
                                                                    +---------------------+
                                                                    |     OBS Overlay     |
                                                                    |    (index.html)     |
                                                                    +---------------------+

```

---

## 🛠 Panduan Instalasi dan Penggunaan

### 1. Persyaratan Sistem

Pastikan perangkat komputer Anda sudah terinstal **Node.js** (Versi 16 atau lebih baru).

### 2. Menjalankan Server Lokal

Ada dua cara untuk menjalankan server backend ini:

* **Cara Otomatis:** Klik ganda pada berkas `start.bat` yang ada di direktori utama proyek. Skrip ini akan menginstal dependensi yang diperlukan secara otomatis dan menyalakan server lokal.
* **Cara Manual:** Buka terminal/command prompt di folder proyek ini, lalu jalankan perintah berikut:
```bash
npm install
node server.js

```


Server akan aktif secara lokal pada alamat `http://localhost:3000` (atau port lain yang dikonfigurasi).

### 3. Konfigurasi di OBS Studio

1. Buka **OBS Studio**.
2. Pada panel **Sources**, klik ikon **+** lalu pilih **Browser**.
3. Beri nama sumber (misal: *Overlay Kajian 4K*).
4. Atur properti Browser Source sebagai berikut:
* **URL:** `http://localhost:3000/index.html` (atau arahkan ke file `index.html` lokal jika disesuaikan).
* **Width:** `3840`
* **Height:** `2160`


5. Klik **OK**.

### 4. Mengoperasikan Tampilan

1. Buka browser Anda (Chrome/Edge/Firefox) lalu akses halaman kontrol di alamat `http://localhost:3000/controller.html`.
2. Isi formulir nama Ustadz, tema kajian, atau running text.
3. Gunakan tombol **Tampilkan di Layar** untuk memunculkan grafis *Lower Third*, atau **Sembunyikan** untuk melakukan *fade out*.

---

## 📝 Catatan Penting untuk Operator

> ⚠️ **Peringatan Protokol File:** Jika Anda membuka berkas `controller.html` secara langsung lewat klik kanan browser (`file:///...`), banner peringatan merah akan muncul. Hubungan real-time dengan OBS memerlukan server lokal aktif (`http://localhost`). Selalu gunakan `start.bat` untuk memulai sesi siaran.

---

## 🛠 Teknologi yang Digunakan

* **HTML5 & CSS3:** CSS Grid, Flexbox, Keyframe Animations, SVG Masking, Custom CSS Variables.
* **Vanilla JavaScript:** Fetch API untuk integrasi data state, asinkronus polling clock, DOM Manipulation.
* **Node.js & Express:** Penyedia layanan REST API ringan untuk sinkronisasi state aplikasi streaming.
