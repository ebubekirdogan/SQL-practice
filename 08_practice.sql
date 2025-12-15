CREATE TABLE "Musteriler" (
 "musteriNo" SERIAL NOT NULL,
 "adi" CHARACTER VARYING(40) COLLATE "pg_catalog"."default" NOT NULL,
 "soyadi" CHARACTER VARYING(40) COLLATE "pg_catalog"."default" NOT NULL,
 CONSTRAINT "musteriNoPK" PRIMARY KEY ("musteriNo")
);

--COLLATE "pg_catalog"."default": Bu kısımmPostgreSQL'in varsayılan sıralama ayarını kullandığını belirtmek için otomatik gelmiştir (örneğin Türkçe karakter sıralaması için).

-- SHOW lc_collate;
--Ne işe yarar?: Veritabanının şu an hangi dil ve karakter seti kurallarına göre sıralama yaptığını gösterir (Örneğin: tr_TR.UTF-8).Database olustururken kullanilir sadece.

CREATE INDEX "musterilerAdiIndex" ON "Musteriler" ("adi");
--Ne işe yarar?: Tablodaki adi sütunu için bir "fihrist" (indeks) oluşturur.
--Faydası: İleride SELECT * FROM "Musteriler" WHERE "adi" = 'Ahmet' dediğinde, veritabanı tüm satırları tek tek gezmek yerine direkt indeksten yerini bulur.

CREATE INDEX "musterilerSoyadiIndex" ON "Musteriler" USING btree ("soyadi");
--Not: PostgreSQL zaten varsayılan olarak B-Tree kullanır, bu kodda yöntem açıkça (USING btree) belirtilmiştir.

DROP INDEX "musterilerAdiIndex";
--Sonuç: Tablodaki veriler silinmez, sadece arama hızlandıran indeks dosyası silinir.

-------------------------------------------------------------------------------------

CREATE TABLE "Kisiler" (
    "kisiNo" SERIAL,
    "adi" VARCHAR(40) NOT NULL,
    "soyadi" VARCHAR(40) NOT NULL,
    "kayitTarihi" TIMESTAMP DEFAULT '2019-01-01 01:00:00',
    CONSTRAINT "urunlerPK1" PRIMARY KEY("kisiNo")
);


CREATE OR REPLACE FUNCTION "veriGir"(kayitSayisi INTEGER)
RETURNS VOID
AS  
$$
BEGIN   
    IF kayitSayisi > 0 THEN
        FOR i IN 1 .. kayitSayisi LOOP
            INSERT INTO "Kisiler" ("adi","soyadi", "kayitTarihi") 
            VALUES(
                substring('ABCÇDEFGĞHIiJKLMNOÖPRSŞTUÜVYZ' from ceil(random()*10)::smallint for ceil(random()*20)::SMALLINT), 
                substring('ABCÇDEFGĞHIiJKLMNOÖPRSŞTUÜVYZ' from ceil(random()*10)::smallint for ceil(random()*20)::SMALLINT),
                NOW() + (random() * (NOW()+'365 days' - NOW()))
                 );
        END LOOP;
    END IF; 
END;
$$
LANGUAGE 'plpgsql'  SECURITY DEFINER;

-- fonksiyon açıklama

/* Bu satır, SQL'e şu emri veriyor: "Bu uzun harf treninden bir parça kesip bana ver."

Bunu yapabilmek için 3 soruya cevap vermesi lazım:

Nereden keseyim? (Kaynak Metin)

Kaçıncı harften başlayayım? (Başlangıç Noktası - FROM)

Kaç harf keseyim? (Uzunluk - FOR)

Detaylı Matematiksel Açılımı:
'ABCÇ...YZ': Bu bizim hammadde depomuz. Bütün harfler burada.

FROM ... (Başlangıç Noktası):

random(): Bilgisayar 0 ile 1 arasında virgüllü bir sayı tutar (Örn: 0.75).

*10: Bunu 10 ile çarpar (Sonuç: 7.5). Yani alfabenin başındaki ilk 10 harften birine denk gelmeye çalışıyoruz.

ceil(...): Sayıyı yukarı yuvarlar (7.5 -> 8 olur).

::smallint: Bu bir "tür dönüşümü"dür. SQL'e "Çıkan sonucu mutlaka tamsayı (integer) olarak kullan, virgülle uğraşma" deriz.

Sonuç: "8. harften (G harfinden) başla."

FOR ... (Uzunluk):

random() * 20: Bu sefer 0 ile 20 arasında bir sayı üretir.

ceil(...): Yukarı yuvarlar. Diyelim ki 5 çıktı.

Sonuç: "Bana 5 harf uzunluğunda bir parça ver."


Tarih kısmı:

Buradaki mantık **"Bugünün üzerine rastgele bir süre ekle"**dir.

NOW(): Şu anki zaman (Örn: 15 Aralık 2025 Saat 14:00).

Parantez İçi (NOW()+'365 days' - NOW()):

Bugüne 365 gün ekle, sonra bugünü çıkar.

Geriye matematiksel olarak tam 1 yıllık süre kalır.

random() * ...:

Bu 1 yıllık süreyi rastgele bir oranla çarp (Örneğin %40'ı ile).

Sonuç: 365 günün %40'ı = 146 gün.

Sonuç: Başlangıçtaki NOW() (Bugün) + 146 gün = Gelecekte rastgele bir tarih.

*/

SELECT "veriGir"(100000);


UPDATE "Kisiler" SET "adi" = 'DENEME' WHERE "kisiNo" = 50;

EXPLAIN ANALYZE
SELECT * FROM "Kisiler"
WHERE "adi" = 'DENEME';
-- index olmadan 9 ms 

CREATE INDEX "adiINDEX" ON "Kisiler" USING btree("adi" ASC);
-- index ile 0.087 ms sürdü.

-- KALITIM
CREATE SCHEMA "personel";

CREATE TABLE "personel"."Personel" (
    "personelNo" SERIAL,
    "adi" VARCHAR(40) NOT NULL,
    "soyadi" VARCHAR(40) NOT NULL,
    "personelTipi" CHAR(1) NOT NULL, 
    CONSTRAINT "personelPK" PRIMARY KEY ("personelNo")
);

CREATE TABLE "personel"."Danisman" (
    "personelNo" INT,
    "sirket" VARCHAR(40) NOT NULL,
    CONSTRAINT "danismanPK" PRIMARY KEY ("personelNo")
);

CREATE TABLE "personel"."SatisTemsilcisi" (
    "personelNo" INT,
    "bolge" VARCHAR(40) NOT NULL,
    CONSTRAINT "satisTemsilcisiPK" PRIMARY KEY ("personelNo")
);

-- Danisman ve SatisTemsilcisi tablolarında personelNo SERIAL değil çünkü ID leri personel tablosundan alacaklar.


-- danısman ve personel bağlantısı
ALTER TABLE "personel"."Danisman"
ADD CONSTRAINT "DanismanPersonel" FOREIGN KEY ("personelNo")
REFERENCES "personel"."Personel" ("personelNo")
ON DELETE CASCADE
ON UPDATE CASCADE;



-- SatisTemsilcisi ve Personel bağlantısı
ALTER TABLE "personel"."SatisTemsilcisi"
ADD CONSTRAINT "SatisTemsilcisiPersonel" FOREIGN KEY ("personelNo")
REFERENCES "personel"."Personel" ("personelNo")
ON DELETE CASCADE
ON UPDATE CASCADE;

-- veri ekleme

INSERT INTO "personel"."Personel" ("adi", "soyadi", "personelTipi")
VALUES ('Mert', 'Şen', 'D');

INSERT INTO "personel"."Danisman" ("personelNo", "sirket")
VALUES (currval('"personel"."Personel_personelNo_seq"'), 'Şen Ltd.');

-- Burada currval komutu, Personel tablosunun sayacından en son üretilen numarayı yakalar ve Danışman tablosuna yazar.

-- fonksiyon ile veri ekleme

DO $$
DECLARE
    genelenPersonelNo integer; -- Numarayı tutacak değişken
BEGIN
    -- 1. Babayı ekle ve oluşan numarayı 'genelenPersonelNo' içine al
    INSERT INTO "personel"."Personel" ("adi", "soyadi", "personelTipi")
    VALUES ('Ali', 'Yılmaz', 'D')
    RETURNING "personelNo" INTO genelenPersonelNo;

    -- 2. Bu numarayı kullanarak çocuğu ekle
    INSERT INTO "personel"."Danisman" ("personelNo", "sirket")
    VALUES (genelenPersonelNo, 'Yılmaz A.Ş.');
END $$;


SELECT * FROM "personel"."Personel"
INNER JOIN "personel"."SatisTemsilcisi"
ON "personel"."Personel"."personelNo" = "personel"."SatisTemsilcisi"."personelNo";

SELECT * FROM "personel"."Personel"
INNER JOIN "personel"."Danisman"
ON "personel"."Personel"."personelNo" = "personel"."Danisman"."personelNo";

-------------------------------------------------------------------------------

-- TEKLİ BAĞINTI 

CREATE TABLE "Personel" (
    "personelNo" SERIAL,
    "adi" VARCHAR(40) NOT NULL,
    "soyadi" VARCHAR(40) NOT NULL,
    "yoneticisi" INTEGER, 
    CONSTRAINT "personelPK" PRIMARY KEY ("personelNo"),
    CONSTRAINT "personelFK" FOREIGN KEY ("yoneticisi") REFERENCES "Personel"("personelNo")
);

INSERT INTO "Personel" ("adi", "soyadi") VALUES ('Ahmet', 'Şahin');
INSERT INTO "Personel" ("adi", "soyadi") VALUES ('Ayşe', 'Kartal');
-- Yoneticisi yok NULL olarka atadı.

INSERT INTO "Personel" ("adi", "soyadi", "yoneticisi") VALUES ('Mustafa', 'Yılmaz', 1);
INSERT INTO "Personel" ("adi", "soyadi", "yoneticisi") VALUES ('Fatma', 'Demir', 1);

SELECT
    "Calisan"."adi" AS "calisanAdi",
    "Calisan"."soyadi" AS "calisanSoyadi",
    "Yonetici"."adi" AS "yoneticiAdi",
    "Yonetici"."soyadi" AS "yoneticiSoyadi"
FROM "Personel" AS "Calisan"
INNER JOIN "Personel" AS "Yonetici"
    ON "Yonetici"."personelNo" = "Calisan"."yoneticisi";

/*
 * SORGUNUN MANTIĞI: Özyineli Birleştirme  -- şuanda sadece personel tablosu var aslında.
 *
 * 1. BİRİNCİ ROLÜN TANIMLANMASI (FROM):
 * FROM "Personel" AS "Calisan"
 *
 * Açıklaması: Sorgunun temel veri kaynağı olarak "Personel" tablosu seçilmiştir.
 * 'AS "Calisan"' ifadesiyle, tabloya bu sorgu özelinde "Calisan" takma adı verilmiştir.
 * Bu işlem, tablonun çalışan verilerini temsil eden taraf olduğunu belirtir.
 *
 * 2. İKİNCİ ROLÜN TANIMLANMASI (INNER JOIN):
 * INNER JOIN "Personel" AS "Yonetici"
 *
 * Açıklaması: Aynı "Personel" tablosunun sanal bir kopyası daha oluşturulmuş ve
 * buna "Yonetici" takma adı verilmiştir. Böylece aynı tablo, iki farklı kimlikle
 * (Yönetici ve Çalışan) işlem görebilir hale gelir.
 *
 * 3. İLİŞKİNİN KURULMASI (ON):
 * ON "Yonetici"."personelNo" = "Calisan"."yoneticisi"
 *
 * Açıklaması: "Çalışan" rolündeki kaydın 'yoneticisi' sütunundaki değer,
 * "Yönetici" rolündeki kaydın 'personelNo' (benzersiz kimlik) değeri ile eşleştirilir.
 * Bu bağlantı sayesinde, çalışanın bağlı olduğu yöneticinin kimlik ve isim bilgilerine erişilir.
 */

SELECT
    "Calisan"."adi" AS "calisanAdi",
    "Calisan"."soyadi" AS "calisanSoyadi",
    "Yonetici"."adi" AS "yoneticiAdi",
    "Yonetici"."soyadi" AS "yoneticiSoyadi"
FROM "Personel" AS "Calisan"
LEFT OUTER JOIN "Personel" AS "Yonetici"
    ON "Yonetici"."personelNo" = "Calisan"."yoneticisi";

-- calisan kısımlarını personel. adi seklinde alsak an sonda birlestirme yaparken personel.personel no ile personel.yoneteticisi aynı iki tabloya birlestirme yapmaya calisacagindan hata alırız. o yüzden calisan,yonetici ve personeli aslında 3 farklı tabloymus gibi alıyoruz ama aslında tek tablo personel.










































  