# 🍃 AgroShop - Toko Pertanian Terpercaya

AgroShop adalah aplikasi marketplace modern yang dirancang khusus untuk memenuhi kebutuhan sektor pertanian. Aplikasi ini memberikan kemudahan bagi petani dan pelaku usaha agribisnis untuk menemukan benih, pupuk, alat pertanian, dan produk agrikultur lainnya dalam satu platform yang intuitif dan responsif.

## ✨ Fitur Utama

- **🚀 Splash Screen & Onboarding**: Pengalaman pengguna yang mulus sejak aplikasi dibuka.
- **🔐 Sistem Autentikasi**: Login dan registrasi yang aman bagi pengguna.
- **🏪 Marketplace Dinamis**: Penjelajahan produk berdasarkan kategori (Benih, Pupuk, Alat, dll).
- **🛒 Manajemen Keranjang**: Sistem shopping cart yang efisien untuk mempermudah pembelian.
- **👤 Profil Pengguna**: Manajemen informasi akun dan riwayat pesanan.
- **📱 Desain Modern**: Interface yang bersih dengan palette warna yang menyegarkan mata, terinspirasi dari alam.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **Language**: [Dart](https://dart.dev/)
- **Networking**: `http` package untuk integrasi REST API
- **Local Storage**: `shared_preferences` untuk persistensi data user
- **Styling**: Custom Theme System (AppColors, AppTheme)

## 📁 Struktur Proyek

```text
lib/
├── core/           # Konfigurasi global (warna, tema, routing, konstanta)
├── features/       # Modul fungsional (auth, cart, home, product, profile)
├── models/         # Data models & dummy data
├── services/       # Integrasi API & Business logic
└── widgets/        # Komponen UI yang reusable
```

## 🚀 Memulai

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) terinstal di sistem Anda.
- Android Studio / VS Code dengan plugin Flutter.
- [AgroShop Backend](https://github.com/muhamadalfinfaizs/Agroshop-Fullstack/tree/main/agroshop-backend) (Pastikan server berjalan).

### Instalasi

1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/muhamadalfinfaizs/Agroshop-Fullstack.git
   ```

2. **Masuk ke direktori frontend:**
   ```bash
   cd agroshop-frontend
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Konfigurasi API:**
   Buka `lib/core/app_constants.dart` dan sesuaikan `baseUrl` dengan alamat server backend Anda.
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000'; // Untuk emulator Android
   ```

5. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

## 📄 Lisensi
Proyek ini dikembangkan untuk tujuan edukasi dan pengembangan agribisnis digital.

---

