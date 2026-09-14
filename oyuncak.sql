-- BÖLÜM 1 – TABLO KURMA

CREATE TABLE oyuncaklar (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    isim TEXT NOT NULL,
    cesit TEXT,
    fiyat REAL CHECK (fiyat > 0),
    renk TEXT DEFAULT 'kırmızı'
);


-- BÖLÜM 2 – EKLEME

-- Renk yazılmadığı için DEFAULT değer olan "kırmızı" olur.
INSERT INTO oyuncaklar (isim, cesit, fiyat)
VALUES ('Şimşek', 'araba', 50);

INSERT INTO oyuncaklar (isim, cesit, fiyat, renk)
VALUES
    ('Ayıcık', 'peluş', 80, 'kahverengi'),
    ('Kale Seti', 'lego', 150, 'gri'),
    ('Zıpzıp', 'top', 20, 'sarı'),
    ('Barbi', 'bebek', 90, 'pembe');


-- BÖLÜM 3 – BULMA

-- Tüm oyuncaklar
SELECT * FROM oyuncaklar;

-- Fiyatı 80 TL ve üzeri
SELECT isim, fiyat
FROM oyuncaklar
WHERE fiyat >= 80;

-- En pahalı 2 oyuncak
SELECT *
FROM oyuncaklar
ORDER BY fiyat DESC
LIMIT 2;

-- İsmi Z ile başlayanlar
SELECT *
FROM oyuncaklar
WHERE isim LIKE 'Z%';

-- Sadece araba ve toplar
SELECT *
FROM oyuncaklar
WHERE cesit IN ('araba', 'top');

-- Fiyatı 20 ile 60 arasında
SELECT *
FROM oyuncaklar
WHERE fiyat BETWEEN 20 AND 60;


-- BÖLÜM 4 – DEĞİŞTİRME VE SİLME

-- Şimşek'in rengini mavi yap
UPDATE oyuncaklar
SET renk = 'mavi'
WHERE isim = 'Şimşek';

-- Zıpzıp'ı sil
DELETE FROM oyuncaklar
WHERE isim = 'Zıpzıp';

-- BONUS
DELETE FROM oyuncaklar;

-- Bu komut tablonun kendisini silmez.
-- Tablodaki TÜM KAYITLARI siler.


-- BÖLÜM 5 – TABLOYU DÜZENLEME

-- Yeni sütun ekle
ALTER TABLE oyuncaklar
ADD COLUMN kimin TEXT;

-- Kale Seti'nin sahibi Ali
UPDATE oyuncaklar
SET kimin = 'Ali'
WHERE isim = 'Kale Seti';

-- cesit sütununun adını tur yap
ALTER TABLE oyuncaklar
RENAME COLUMN cesit TO tur;