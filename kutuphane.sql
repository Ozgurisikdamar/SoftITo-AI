-- =====================================================
-- SQLite Kütüphane Uygulaması
-- DB dosyası: kutuphane.sqlite
-- =====================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- 1. TABLO TASARIMI VE KISITLAR
-- =====================================================

CREATE TABLE uyeler (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad TEXT NOT NULL,
    yas INTEGER NOT NULL CHECK (yas > 13),
    sehir TEXT DEFAULT 'Erzincan',
    kayit DATETIME DEFAULT CURRENT_TIMESTAMP,
    eposta TEXT
);

CREATE TABLE kitaplar (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    kitap_adi TEXT NOT NULL UNIQUE
);

CREATE TABLE odunc (
    uye_id INTEGER NOT NULL,
    kitap_id INTEGER NOT NULL,
    gun INTEGER NOT NULL CHECK (gun BETWEEN 3 AND 45),

    PRIMARY KEY (uye_id, kitap_id),

    FOREIGN KEY (uye_id)
        REFERENCES uyeler(id)
        ON DELETE CASCADE,

    FOREIGN KEY (kitap_id)
        REFERENCES kitaplar(id)
);

CREATE INDEX idx_uyeler_ad
ON uyeler(ad);

CREATE UNIQUE INDEX idx_uyeler_eposta_unique
ON uyeler(eposta);

-- =====================================================
-- 2. VERİ EKLEME
-- =====================================================

INSERT INTO kitaplar (kitap_adi) VALUES
('Suç ve Ceza'),
('1984'),
('Simyacı'),
('Kürk Mantolu Madonna'),
('Sefiller');

INSERT INTO uyeler (ad, yas, sehir, eposta) VALUES
('Ahmet', 25, 'İstanbul', 'ahmet@example.com'),
('Mehmet', 32, 'Ankara', 'mehmet@example.com'),
('Ayşe', 19, 'İzmir', 'ayse@example.com'),
('Fatma', 42, 'Erzurum', 'fatma@example.com'),
('Mert', 17, 'Bursa', 'mert@example.com');

-- Şehir belirtilmezse varsayılan olarak Erzincan atanır.
INSERT INTO uyeler (ad, yas, eposta) VALUES
('Zeynep', 24, 'zeynep@example.com'),
('Can', 30, 'can@example.com'),
('Elif', 16, 'elif@example.com'),
('Burak', 35, 'burak@example.com'),
('Deniz', 22, 'deniz@example.com');

-- CHECK testi: çalıştırılırsa hata verir.
-- INSERT INTO uyeler (ad, yas) VALUES ('Çocuk Üye', 10);

-- FK testi: çalıştırılırsa hata verir.
-- INSERT INTO odunc (uye_id, kitap_id, gun) VALUES (99, 1, 15);

INSERT INTO odunc (uye_id, kitap_id, gun) VALUES
(1, 1, 10),
(1, 2, 35),
(2, 2, 25),
(2, 3, 40),
(3, 3, 12),
(3, 4, 32),
(4, 4, 20),
(4, 5, 45),
(5, 5, 8),
(5, 1, 18),
(6, 1, 30),
(6, 3, 38),
(7, 2, 15),
(7, 4, 42),
(8, 3, 6),
(8, 5, 28),
(9, 4, 34),
(9, 1, 22),
(10, 5, 14),
(10, 2, 37);

-- =====================================================
-- 3. JOIN
-- =====================================================

-- Üye adı, kitap adı ve gün sayısı
SELECT
    u.ad AS uye,
    k.kitap_adi AS kitap,
    o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id;

-- 30 günden uzun tutulan kitaplar
SELECT
    u.ad AS uye,
    k.kitap_adi AS kitap,
    o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE o.gun > 30;

-- Sadece Erzincan'daki üyelerin ödünç aldığı kitaplar
SELECT
    u.ad AS uye,
    k.kitap_adi AS kitap,
    o.gun
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE u.sehir = 'Erzincan';

-- Hiç kitap almamış üyeleri de göstermek için LEFT JOIN
SELECT
    u.ad AS uye,
    k.kitap_adi AS kitap,
    o.gun
FROM uyeler u
LEFT JOIN odunc o ON u.id = o.uye_id
LEFT JOIN kitaplar k ON k.id = o.kitap_id;

-- =====================================================
-- 4. GRUPLAMA VE TOPLAMA FONKSİYONLARI
-- =====================================================

-- Her üyenin ortalama süresi, kitap sayısı, en uzun süresi
SELECT
    u.id,
    u.ad,
    AVG(o.gun) AS ortalama_gun,
    COUNT(o.kitap_id) AS kitap_sayisi,
    MAX(o.gun) AS en_uzun_sure
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
GROUP BY u.id, u.ad;

-- Ortalaması 20 günün üzerinde olan üyeler
SELECT
    u.id,
    u.ad,
    AVG(o.gun) AS ortalama_gun,
    COUNT(o.kitap_id) AS kitap_sayisi,
    MAX(o.gun) AS en_uzun_sure
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
GROUP BY u.id, u.ad
HAVING AVG(o.gun) > 20;

-- HAVING, GROUP BY sonrası oluşan grupları filtreler.
-- WHERE ise gruplamadan önce satırları filtreler.

-- Her kitabın kaç kez ödünç alındığı
SELECT
    k.kitap_adi,
    COUNT(o.uye_id) AS odunc_sayisi
FROM kitaplar k
LEFT JOIN odunc o ON k.id = o.kitap_id
GROUP BY k.id, k.kitap_adi
ORDER BY odunc_sayisi DESC;

-- Şehirlere göre üye sayısı
SELECT
    sehir,
    COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;

-- =====================================================
-- 5. ALT SORGU
-- =====================================================

-- En az bir kitabı 30 günden uzun tutmuş üyeler
SELECT ad
FROM uyeler
WHERE id IN (
    SELECT uye_id
    FROM odunc
    WHERE gun > 30
);

-- Hiç ödünç alınmamış kitaplar
SELECT *
FROM kitaplar
WHERE id NOT IN (
    SELECT kitap_id
    FROM odunc
);

-- Genel ortalamanın üzerinde süre tutulan kayıtlar
SELECT *
FROM odunc
WHERE gun > (
    SELECT AVG(gun)
    FROM odunc
);

-- =====================================================
-- 6. CASE
-- =====================================================

-- Ödünç durumları
SELECT
    uye_id,
    kitap_id,
    gun,
    CASE
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum
FROM odunc;

-- Üyeleri yaşına göre etiketleme
SELECT
    id,
    ad,
    yas,
    CASE
        WHEN yas <= 18 THEN 'Genç'
        ELSE 'Yetişkin'
    END AS yas_grubu
FROM uyeler;

-- Her durumdan kaç kayıt var?
SELECT
    CASE
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum,
    COUNT(*) AS kayit_sayisi
FROM odunc
GROUP BY
    CASE
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END;

-- =====================================================
-- 7. INDEX
-- =====================================================

-- idx_uyeler_ad özellikle ada göre aramaları hızlandırır:
SELECT *
FROM uyeler
WHERE ad = 'Ahmet';

-- UNIQUE index nedeniyle aşağıdaki işlem hata verir:
-- UPDATE uyeler
-- SET eposta = 'ahmet@example.com'
-- WHERE id = 2;

-- =====================================================
-- SİLME DAVRANIŞI
-- =====================================================

-- Bir üye silinirse, ON DELETE CASCADE nedeniyle
-- o üyeye ait odunc kayıtları da silinir.

-- Bir kitap odunc tablosunda kullanılıyorsa ve silinmeye çalışılırsa
-- ON DELETE CASCADE tanımlı olmadığı için FOREIGN KEY hatası alınır.
