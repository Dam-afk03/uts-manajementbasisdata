-- 1. Tabel relasi
CREATE TABLE salam.matakuliah (
    kode VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    sks  SMALLINT NOT NULL CHECK (sks BETWEEN 1 AND 6)
);

CREATE TABLE salam.krs (
    id           SERIAL PRIMARY KEY,
    mahasiswa_id INT NOT NULL REFERENCES salam.mahasiswas(id) ON DELETE CASCADE,
    kode_mk      VARCHAR(10) NOT NULL REFERENCES salam.matakuliah(kode),
    nilai        CHAR(1) CHECK (nilai IN ('A','B','C','D','E')),
    UNIQUE (mahasiswa_id, kode_mk)
);

INSERT INTO salam.matakuliah VALUES
 ('MBD01','Manajemen Basis Data',3),
 ('PWB01','Pemrograman Web',3);

INSERT INTO salam.krs (mahasiswa_id, kode_mk, nilai)
SELECT id, 'MBD01', 'A' FROM salam.mahasiswas WHERE nim = '1247050024';

-- 2. Trigger updated_at
ALTER TABLE salam.mahasiswas ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();

CREATE OR REPLACE FUNCTION salam.set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mahasiswas_updated
BEFORE UPDATE ON salam.mahasiswas
FOR EACH ROW EXECUTE FUNCTION salam.set_updated_at();

-- 3. View ringkasan
CREATE VIEW salam.v_ringkasan_mahasiswa AS
SELECT m.nim, m.nama, m.ipk,
       COUNT(k.id) AS jumlah_mk,
       COALESCE(SUM(mk.sks), 0) AS total_sks
FROM salam.mahasiswas m
LEFT JOIN salam.krs k ON k.mahasiswa_id = m.id
LEFT JOIN salam.matakuliah mk ON mk.kode = k.kode_mk
GROUP BY m.nim, m.nama, m.ipk;