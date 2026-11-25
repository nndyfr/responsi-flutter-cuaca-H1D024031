# Aplikasi Cuaca (Responsi Flutter)

Aplikasi cuaca berbasis Flutter yang dikembangkan menggunakan arsitektur **MVVM (Model-View-ViewModel)** dan memanfaatkan **Open-Meteo REST API**.

---

## 👤 Identitas Mahasiswa
* **Nama:** Nindya Alif Romland
* **NIM:** H1D024031
* **Shift Awal:** D
* **Shift Baru:** E

---

## 📱 Struktur Aplikasi & Arsitektur MVVM

Aplikasi ini menerapkan pola arsitektur **MVVM** untuk memisahkan logika bisnis, pengelolaan state, dan antarmuka pengguna secara bersih:

```text
lib/
│
├── models/             # Model Data (Representasi JSON dari API & Local Storage)
│   ├── location_model.dart
│   └── weather_model.dart
│
├── services/           # Layanan Jaringan & Penyimpanan Lokal
│   ├── weather_service.dart   # Mengambil data dari Open-Meteo API (Geocoding & Forecast)
│   └── storage_service.dart   # Menyimpan lokasi favorit & riwayat menggunakan SharedPreferences
│
├── viewmodels/         # ViewModel (Pengelolaan State Menggunakan Provider)
│   ├── weather_viewmodel.dart # Mengelola state cuaca kota terpilih
│   ├── search_viewmodel.dart  # Mengelola pencarian kota & daftar favorit
│   └── view_state.dart        # Enum status UI (idle, loading, success, empty, error)
│
└── views/              # Antarmuka Pengguna (Screen & Widget)
    ├── home_screen.dart       # Screen Utama (Cuaca terkini & prakiraan harian)
    ├── search_screen.dart     # Screen Pencarian & Pengelolaan Favorit
    └── weather_icons.dart     # Helper konversi kode cuaca WMO ke ikon Material
```

---

## 🌐 Implementasi API (Open-Meteo)

Aplikasi menggunakan **Open-Meteo API** secara langsung melalui metode HTTP GET:
1. **Geocoding API** (`https://geocoding-api.open-meteo.com/v1/search`): Digunakan untuk mencari koordinat lintang dan bujur berdasarkan nama kota yang dimasukkan pengguna.
2. **Weather Forecast API** (`https://api.open-meteo.com/v1/forecast`): Mengambil data cuaca terkini (`current`) dan prakiraan harian (`daily`).

Data cuaca yang ditampilkan mencakup:
- Suhu saat ini (`current.temperature_2m`)
- Suhu yang dirasakan (`current.apparent_temperature`)
- Kelembapan udara (`current.relative_humidity_2m`)
- Kecepatan angin (`current.wind_speed_10m`)
- Curah hujan & peluang hujan (`current.precipitation`, `daily.precipitation_probability_max`)
- Prakiraan cuaca harian (`daily.temperature_2m_max`, `daily.temperature_2m_min`, dll.)

---

## 🖥️ Screen & Fitur Utama

1. **Home / Weather Screen (`HomeScreen`)**
   - Menampilkan nama kota yang sedang dipilih.
   - Menampilkan kondisi cuaca terkini, ikon cuaca, dan suhu saat ini.
   - Menampilkan informasi tambahan (kelembapan, kecepatan angin, suhu dirasakan, curah hujan, peluang hujan).
   - Menampilkan perkiraan cuaca beberapa hari ke depan.
   - Mendukung fitur *Pull-to-Refresh* untuk memperbarui data cuaca.

2. **Search / Location Screen (`SearchScreen`)**
   - Menyediakan kolom input untuk mencari kota berdasarkan nama.
   - Menampilkan daftar hasil pencarian lokasi dari Geocoding API.
   - Memungkinkan pengguna memilih lokasi untuk melihat informasi cuacanya.
   - Menyediakan fitur menyimpan lokasi sebagai **Favorit** yang tersimpan secara lokal menggunakan `SharedPreferences`.

---

## 📸 Screenshot Aplikasi

### Screen Utama
| Home / Weather Screen | Search Screen |
| :---: | :---: |
| <img src="screenshots/home.png" width="220"> | <img src="screenshots/search.png" width="220"> |
| Cuaca kota terpilih, suhu, kelembapan, angin, peluang hujan, & perkiraan harian | Kolom pencarian kota |

### Pencarian dan Favorit
| Hasil Pencarian | Lokasi Favorit |
| :---: | :---: |
| <img src="screenshots/hasil-pencarian.png" width="220"> | <img src="screenshots/favorit.png" width="220"> |
| Daftar hasil setelah mencari nama kota | Daftar lokasi favorit yang tersimpan di local storage |

### Kondisi Aplikasi
| Loading | Data Kosong | Error |
| :---: | :---: | :---: |
| <img src="screenshots/loading.png" width="220"> | <img src="screenshots/kosong.png" width="220"> | <img src="screenshots/error.png" width="220"> |
| Kondisi saat data diambil dari API | Kondisi "Kota tidak ditemukan" | Kondisi error beserta tombol "Coba lagi" |
