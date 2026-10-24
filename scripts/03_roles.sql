-- Soal 4: pembuatan user dan hak akses
-- Jalankan sebagai user postgres

-- Buat user
CREATE USER backend_dev   WITH PASSWORD 'backend123';
CREATE USER bi_dev        WITH PASSWORD 'bi123';
CREATE USER data_engineer WITH PASSWORD 'engineer123';

-- Izin koneksi ke database
GRANT CONNECT ON DATABASE uts_db TO backend_dev, bi_dev, data_engineer;

-- a. backend_dev: CRUD semua tabel
GRANT USAGE ON SCHEMA salam TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA salam TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA salam TO backend_dev;

-- b. bi_dev: hanya read/select semua tabel dan view
GRANT USAGE ON SCHEMA salam TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA salam TO bi_dev;

-- c. data_engineer: CREATE, MODIFY, DROP semua objek + CRUD semua tabel
--    (agar bisa ALTER/DROP, data_engineer dijadikan pemilik schema dan tabel)
ALTER SCHEMA salam OWNER TO data_engineer;
ALTER TABLE salam.mahasiswas OWNER TO data_engineer;
ALTER SEQUENCE salam.mahasiswas_id_seq OWNER TO data_engineer;

-- Objek baru yang dibuat data_engineer otomatis bisa diakses user lain
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT ON TABLES TO bi_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;
