# Photobooth API (Backend)

REST API untuk aplikasi mobile Photobooth. Dibangun dengan **Node.js + Express** dan **SQLite** (via `better-sqlite3`) sehingga tidak perlu instalasi database server terpisah — cukup `npm install` dan langsung jalan (local API), tapi juga bisa dideploy ke hosting (Railway, Render, VPS, dst) untuk dipakai sebagai API internet.

## 1. Instalasi

```bash
cd backend
npm install
cp .env.example .env
npm run seed     # isi data awal frames & filters
npm start        # jalankan server di http://localhost:3000
```

Untuk development dengan auto-reload:

```bash
npm run dev
```

## 2. Konfigurasi (`.env`)

| Variabel     | Keterangan                                  | Default                        |
|--------------|----------------------------------------------|---------------------------------|
| `PORT`       | Port server Express                          | `3000`                          |
| `JWT_SECRET` | Secret key untuk signing token JWT           | `photobooth_secret_key_change_me` |

## 3. Struktur Folder

```
backend/
├── src/
│   ├── config/database.js     # koneksi SQLite + schema (CREATE TABLE)
│   ├── models/                # query layer per tabel (7 model)
│   ├── controllers/            # logic request/response tiap resource
│   ├── middleware/             # auth JWT, upload (multer)
│   ├── routes/                 # definisi endpoint per resource
│   └── server.js               # entrypoint Express
├── database/
│   ├── photobooth.sqlite       # file database (dibuat otomatis saat run)
│   └── seed.js                 # seeder data awal (frames & filters)
└── uploads/                     # tempat file foto/stiker hasil upload
```

## 4. Autentikasi

Semua endpoint (kecuali `/auth/register` dan `/auth/login`) membutuhkan header:

```
Authorization: Bearer <token>
```

Token didapat dari response `register`/`login`, berlaku 7 hari (JWT).

## 5. Daftar Endpoint

### Auth
| Method | Endpoint            | Keterangan            |
|--------|----------------------|------------------------|
| POST   | `/api/auth/register`| Registrasi akun baru   |
| POST   | `/api/auth/login`   | Login, dapatkan token  |
| GET    | `/api/auth/me`      | Profil user yang login |

### Users
| Method | Endpoint          | Keterangan          |
|--------|-------------------|----------------------|
| GET    | `/api/users/:id`  | Lihat profil user    |
| PUT    | `/api/users/me`   | Update nama/avatar   |

### Frames (master data — CRUD penuh)
| Method | Endpoint           | Keterangan        |
|--------|--------------------|--------------------|
| GET    | `/api/frames`      | Daftar frame       |
| GET    | `/api/frames/:id`  | Detail frame       |
| POST   | `/api/frames`      | Tambah frame       |
| PUT    | `/api/frames/:id`  | Ubah frame         |
| DELETE | `/api/frames/:id`  | Hapus (soft delete)|

### Filters (master data — CRUD penuh)
| Method | Endpoint                        | Keterangan                          |
|--------|----------------------------------|---------------------------------------|
| GET    | `/api/filters`                  | Daftar filter                        |
| GET    | `/api/filters?type=vibe_lighting`| Filter berdasar tipe (color/vibe_lighting/beauty) |
| GET    | `/api/filters/:id`               | Detail filter                        |
| POST   | `/api/filters`                   | Tambah filter                        |
| PUT    | `/api/filters/:id`                | Ubah filter                          |
| DELETE | `/api/filters/:id`                | Hapus filter                         |

### Sessions / Strip (My Gallery, Strip Detail, Final Preview)
| Method | Endpoint                        | Keterangan                                   |
|--------|----------------------------------|-----------------------------------------------|
| GET    | `/api/sessions`                 | Daftar strip milik user login (My Gallery)    |
| POST   | `/api/sessions`                 | Simpan strip baru (dari Final Preview)        |
| GET    | `/api/sessions/:id`              | Detail strip + foto + dekorasi (Strip Detail) |
| PUT    | `/api/sessions/:id`               | Update judul/frame/favorit (Decorate Strip)   |
| DELETE | `/api/sessions/:id`               | Hapus strip dari galeri                       |
| POST   | `/api/sessions/:id/photos`        | Tambah foto ke strip                          |
| POST   | `/api/sessions/:id/decorations`   | Tambah stiker/teks/emoji ke strip             |

### Photos
| Method | Endpoint          | Keterangan                          |
|--------|-------------------|---------------------------------------|
| PUT    | `/api/photos/:id` | Update filter/urutan/beauty pada foto |
| DELETE | `/api/photos/:id` | Hapus foto dari strip                 |

### Decorations
| Method | Endpoint               | Keterangan                       |
|--------|------------------------|-------------------------------------|
| PUT    | `/api/decorations/:id`| Update posisi/isi dekorasi          |
| DELETE | `/api/decorations/:id`| Hapus dekorasi                      |

### Settings (App Settings)
| Method | Endpoint        | Keterangan                                   |
|--------|-----------------|-------------------------------------------------|
| GET    | `/api/settings` | Ambil preferensi user (auto-create jika belum ada) |
| PUT    | `/api/settings` | Update preferensi (resolusi, watermark, dll)   |

### Upload
| Method | Endpoint       | Keterangan                                  |
|--------|----------------|------------------------------------------------|
| POST   | `/api/uploads` | Upload gambar (multipart, field `image`), balikan `path` |

## 6. Contoh Request (cURL)

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Naufal","email":"naufal@test.com","password":"secret123"}'

# Simpan strip baru (pakai token dari hasil register/login)
curl -X POST http://localhost:3000/api/sessions \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"frame_id":1,"title":"Liburan Bareng Teman","layout_type":"4-cut","photos":[{"image_path":"/uploads/dummy1.jpg","filter_id":1,"order_index":0}]}'
```

## 7. Catatan

- Database SQLite otomatis dibuat di `database/photobooth.sqlite` saat server pertama kali dijalankan (tidak perlu setup MySQL/PostgreSQL terpisah). Cocok untuk demo tugas besar, tapi bisa diganti ke MySQL/PostgreSQL dengan menyesuaikan `src/config/database.js` bila backend ingin dihosting untuk produksi.
- Endpoint sudah teruji lengkap end-to-end (register → login → CRUD frame/filter → buat strip → tambah foto & dekorasi → update settings) sebelum dikemas ke ZIP ini.
