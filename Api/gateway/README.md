# Agroshop Gateway

Gateway ini menjadi pintu depan API untuk frontend.

Alur:

```txt
Frontend -> Gateway port 3003 -> Backend port 3000 -> Database
```

Cara menjalankan:

```bash
cd C:\ProjectFlutter\Agroshop\agroshop-gateway
npm run start
```

Backend utama tetap harus berjalan:

```bash
cd C:\ProjectFlutter\Agroshop\agroshop-backend
npm run start
```

Contoh akses:

```txt
GET http://localhost:3003/api/products
```

Gateway akan meneruskan request tersebut menjadi:

```txt
GET http://localhost:3000/products
```

Kalau ingin mengganti alamat backend:

```bash
set BACKEND_URL=http://localhost:3000
npm run start
```
