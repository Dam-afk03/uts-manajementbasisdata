# UTS Manajemen Basis Data: PostgreSQL + pgAdmin4 dengan Docker Compose

| | |
|---|---|
| **Nama** | Adam Halawi |
| **NIM** | 1247050024 |
| **Kelas** | A |
| **Mata Kuliah** | Manajemen Basis Data |
| **Dosen** | Wildan Budiawan Z, S.T., M.Kom |

Project ini menjalankan PostgreSQL dan pgAdmin4 memakai Docker Compose, lengkap dengan schema, tabel, constraint, dan pengaturan hak akses user.

## Isi Repository

```
.
├── docker-compose.yml        # definisi service PostgreSQL & pgAdmin4
├── .env.example              # contoh isi file .env
├── .gitignore
├── README.md
└── scripts/
    ├── 01_schema.sql             # schema salam + tabel mahasiswas (PK, UNIQUE, CHECK)
    ├── 02_test_constraint.sql    # uji constraint
    ├── 03_roles.sql              # pembuatan user & hak akses
    ├── 04_test_roles.sql         # uji hak akses tiap user
    └── 05_fitur_tambahan.sql     # tabel relasi, trigger, view
```

## Service

| Service | Container | Image | Port Host | Port Container |
|---|---|---|---|---|
| PostgreSQL | `postgres_adam` | `postgres:15` | `22024` | `5432` |
| pgAdmin4 | `pgadmin_adam` | `dpage/pgadmin4:latest` | `44024` | `80` |

Username dan password tidak ditulis langsung di `docker-compose.yml`, tetapi dibaca dari file `.env`.

## Cara Menjalankan

**Prasyarat:** Docker Desktop sudah terpasang dan berjalan.

1. Clone repository ini:
   ```bash
   git clone https://github.com/Dam-afk03/uts-manajementbasisdata.git
   cd uts-manajementbasisdata
   ```
2. Salin `.env.example` menjadi `.env`, lalu isi nilainya:
   ```bash
   cp .env.example .env        # Windows CMD: copy .env.example .env
   ```
   ```env
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=ifunggul
   POSTGRES_DB=uts_db
   PGADMIN_EMAIL=admin@example.com
   PGADMIN_PASSWORD=<isi_sendiri>
   ```
3. Jalankan container:
   ```bash
   docker compose up -d
   docker compose ps
   ```
4. Hentikan container:
   ```bash
   docker compose down        # data tetap tersimpan di volume
   docker compose down -v     # hapus juga volume (data hilang)
   ```

## Akses PostgreSQL

**Dari internal Docker (pgAdmin4)**
- Buka `http://localhost:44024`, login memakai `PGADMIN_EMAIL` dan `PGADMIN_PASSWORD`.
- Register server dengan Host `postgres` (nama service), Port `5432`, Database `uts_db`, Username `postgres`.

**Dari eksternal Docker (DBeaver)**
- Host `localhost`, Port `22024`, Database `uts_db`, Username `postgres`.

## Menjalankan Script SQL

Jalankan berurutan, bisa lewat DBeaver (Alt+X) atau terminal. Contoh lewat terminal:

```bash
docker exec -i -e PGPASSWORD=ifunggul postgres_adam psql -U postgres -d uts_db < scripts/01_schema.sql
docker exec -i -e PGPASSWORD=ifunggul postgres_adam psql -U postgres -d uts_db < scripts/03_roles.sql
```

`05_fitur_tambahan.sql` dijalankan sebagai `data_engineer` supaya objek barunya otomatis bisa diakses user lain:

```bash
docker exec -i -e PGPASSWORD=engineer123 postgres_adam psql -U data_engineer -d uts_db < scripts/05_fitur_tambahan.sql
```

## Struktur Database

Schema `salam` berisi tabel:

- **`mahasiswas`**: PRIMARY KEY (`id`), UNIQUE (`nim`, `email`), CHECK (`semester` 1-14, `ipk` 0-4)
- **`matakuliah`**: PRIMARY KEY (`kode`), CHECK (`sks` 1-6)
- **`krs`**: FOREIGN KEY ke `mahasiswas` dan `matakuliah`, UNIQUE (`mahasiswa_id`, `kode_mk`)
- **`v_ringkasan_mahasiswa`** (view): jumlah mata kuliah dan total SKS per mahasiswa

## User dan Hak Akses

| User | Password | Hak akses |
|---|---|---|
| `backend_dev` | `backend123` | CRUD (SELECT, INSERT, UPDATE, DELETE) semua tabel |
| `bi_dev` | `bi123` | Hanya SELECT semua tabel dan view |
| `data_engineer` | `engineer123` | CREATE, ALTER, DROP semua objek, plus CRUD semua tabel |

> Password di atas hanya untuk keperluan tugas kuliah, jangan dipakai di lingkungan produksi.

Contoh pengujian:

```bash
# backend_dev: INSERT berhasil, CREATE TABLE ditolak
docker exec -e PGPASSWORD=backend123 postgres_adam psql -U backend_dev -d uts_db -c "CREATE TABLE salam.coba (id int);"

# bi_dev: SELECT berhasil, INSERT/DELETE ditolak
docker exec -e PGPASSWORD=bi123 postgres_adam psql -U bi_dev -d uts_db -c "SELECT * FROM salam.mahasiswas;"
```

## Fitur Tambahan

- **Tabel relasi** `matakuliah` dan `krs` dengan FOREIGN KEY (`ON DELETE CASCADE` pada `krs.mahasiswa_id`)
- **Trigger** `trg_mahasiswas_updated`: kolom `updated_at` terisi otomatis setiap data `mahasiswas` diubah
- **View** `v_ringkasan_mahasiswa`: ringkasan jumlah mata kuliah dan total SKS, bisa dibaca `bi_dev`
- **Healthcheck** PostgreSQL dan `depends_on` kondisi `service_healthy`, sehingga pgAdmin baru berjalan setelah database siap
- **Named volume** (`pgdata`, `pgadmin_data`) agar data tidak hilang saat container dibuat ulang
