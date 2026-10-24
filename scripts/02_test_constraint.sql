-- Soal 3: pengujian constraint pada salam.mahasiswas
-- Jalankan satu per satu

-- Data valid (harus BERHASIL)
INSERT INTO salam.mahasiswas (nim, nama, email, semester, ipk)
VALUES ('1247050024', 'Adam Halawi', 'adam@mail.com', 4, 3.50);

-- Uji PRIMARY KEY (harus GAGAL: duplicate key ... mahasiswas_pkey)
INSERT INTO salam.mahasiswas (id, nim, nama, email, semester, ipk)
VALUES (1, '1247050099', 'Test PK', 'pk@mail.com', 4, 3.00);

-- Uji UNIQUE (harus GAGAL: duplicate key ... mahasiswas_nim_key)
INSERT INTO salam.mahasiswas (nim, nama, email, semester, ipk)
VALUES ('1247050024', 'Test Unique', 'x@mail.com', 4, 3.00);

-- Uji CHECK (harus GAGAL: violates check constraint mahasiswas_ipk_check)
INSERT INTO salam.mahasiswas (nim, nama, email, semester, ipk)
VALUES ('1247050055', 'Test Check', 'y@mail.com', 4, 5.00);

SELECT * FROM salam.mahasiswas;
