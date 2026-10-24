-- Soal 4: pengujian hak akses tiap user
-- Jalankan tiap blok memakai koneksi user yang bersangkutan
-- (lewat DBeaver, atau lewat terminal dengan: docker exec -e PGPASSWORD=... postgres_adam psql -U <user> -d uts_db -c "...")

-- ===== backend_dev (password: backend123) =====
INSERT INTO salam.mahasiswas (nim, nama, email, semester, ipk)
VALUES ('1247050001', 'Budi', 'budi@mail.com', 4, 3.2);      -- BERHASIL
UPDATE salam.mahasiswas SET ipk = 3.4 WHERE nim = '1247050001';  -- BERHASIL
DELETE FROM salam.mahasiswas WHERE nim = '1247050001';           -- BERHASIL
CREATE TABLE salam.coba (id int);                                -- GAGAL (permission denied for schema salam)

-- ===== bi_dev (password: bi123) =====
SELECT * FROM salam.mahasiswas;                                  -- BERHASIL
INSERT INTO salam.mahasiswas (nim, nama) VALUES ('1', 'x');      -- GAGAL (permission denied)
DELETE FROM salam.mahasiswas;                                    -- GAGAL (permission denied)

-- ===== data_engineer (password: engineer123) =====
CREATE TABLE salam.matakuliah_tes (id serial PRIMARY KEY, nama varchar(50));  -- BERHASIL
ALTER TABLE salam.matakuliah_tes ADD COLUMN sks int;                          -- BERHASIL
INSERT INTO salam.matakuliah_tes (nama, sks) VALUES ('Basis Data', 3);        -- BERHASIL
DROP TABLE salam.matakuliah_tes;                                              -- BERHASIL
