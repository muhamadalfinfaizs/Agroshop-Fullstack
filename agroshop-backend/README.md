# 🌿 AgroShop Backend API

Repositori ini berisi kode sumber backend untuk platform *e-commerce* pertanian, AgroShop. Sistem ini dirancang khusus untuk menangani transaksi dan etalase produk pertanian, dikembangkan menggunakan TypeScript, NestJS, dan Prisma.

## 🚀 Fitur Utama

*   **Autentikasi Aman (JWT):** Mengimplementasikan otentikasi berbasis *JSON Web Token* (Passport-JWT) dan enkripsi *password* menggunakan Bcrypt.
*   **Role-Based Access Control (RBAC):** Sistem otorisasi berlapis dengan pemisahan hak akses yang ketat antara `ADMIN` (pengelola toko/CMS) dan `FARMER` (pengguna/pembeli).
*   **Manajemen Etalase Toko (Katalog):** API CRUD lengkap untuk entitas `Categories`, `Products`, dan `Banners`. Rute *Read* (GET) terbuka untuk publik, sementara manipulasi data dilindungi khusus untuk Admin.
*   **Sistem Keranjang Belanja (Cart):** Manajemen *cart* yang terisolasi dan aman; secara otomatis mendeteksi kepemilikan keranjang berdasarkan token pengguna yang sedang *login*.
*   **Standar Respons Terpusat:** Menggunakan *Exception Handling* khusus agar seluruh *endpoint* selalu mengembalikan struktur JSON yang baku untuk mempermudah integrasi *Frontend*.

## 🛠️ Teknologi yang Digunakan

*   **Framework:** NestJS (TypeScript)
*   **ORM:** Prisma
*   **Database:** PostgreSQL
*   **Autentikasi:** Passport-JWT, Bcrypt
*   **Testing Tool:** Apidog

## 📦 Standar Format Respons API

Untuk memudahkan proses *parsing* data di aplikasi *Frontend* (Flutter/React), setiap respons API mematuhi struktur baku berikut:

```json
{
  "success": true,
  "message": "Pesan deskripsi proses (contoh: Data berhasil diambil)",
  "metadata": {
    "status": 200,
    "total_data": 10
  },
  "data": [
    // Array atau Object data akan berada di sini
  ]
}