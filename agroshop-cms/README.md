# Agroshop CMS

CMS ini adalah dashboard admin berbasis React untuk mengelola data Agroshop.

Alur koneksi:

```txt
CMS React -> Gateway 3003 -> Backend 3000 -> Database
```

Cara menjalankan:

```bash
cd C:\ProjectFlutter\Agroshop\agroshop-backend
npm run start
```

Terminal kedua:

```bash
cd C:\ProjectFlutter\Agroshop\agroshop-gateway
npm run start
```

Terminal ketiga:

```bash
cd C:\ProjectFlutter\Agroshop\agroshop-cms
npm run dev
```

CMS berjalan di:

```txt
http://localhost:5174
```

Base URL API default:

```txt
http://localhost:3003/api
```

Fitur basic:

- Login admin
- Dashboard ringkas
- Kelola kategori
- Kelola produk
- Kelola banner
- Lihat pesanan
- Update data pengiriman
- Lihat data user

Catatan:

- Gunakan akun dengan role `ADMIN`.
- Backend dan gateway harus berjalan sebelum CMS dipakai.
- Jika ingin mengganti base URL API, buat file `.env` dan isi:

```txt
VITE_API_BASE_URL=http://localhost:3003/api
```
