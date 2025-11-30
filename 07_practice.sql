CREATE DATABASE "SQL_deneme_slayt07"
ENCODING = 'UTF-8'
LC_COLLATE='tr_TR.UTF-8'
LC_CTYPE='tr_TR.UTF-8'
OWNER postgres
TEMPLATE=template0;
--VERİTABANI OLUŞTURMA

CREATE SCHEMA "sema1";
-- ŞEMA OLUŞTURMA

SET search_path TO "sema1"; --her defasında "sema1"."Urunler" yazmamak icin



CREATE TABLE "sema1"."Urunler" (
"urunNo" SERIAL, -- BENZERSİZ VE OTOMATIK OLARAK ARTAN BİR PK DEĞERİ ATAR.
"kodu" CHAR(6) NOT NULL, -- 6 UZUNLUGUNDA BİR KARAKTER DİZİSİ, 6DAN KISAYSA BOŞLUKLA TAMAMLANIR
"adi" VARCHAR(40) NOT NULL, -- UZUNLUGU BILINMEYEN,DEGİSKEN UZUNLUKTA KARAKTER DIZISI, MAX 40 KARAKTER TUTABILIR.
"uretimTarihi" DATE DEFAULT '2019-01-01', --YIL-AY-GUN BILGISI TUTAR
"birimFiyati" MONEY, -- PARA BIRIMI DEĞERLERİ TUTAR. ($)
"miktari" SMALLINT DEFAULT 0, -- KÜÇÜK BİR TAMSAYI TUTMAK İÇİN KULLANILIR

-- KISITLAMALAR (CONSTRAINT)
 CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"), -- Kısıtlamaya, ileride yönetim ve hata mesajlarında kullanmak üzere urunlerPK adını verir. urunNo sütununu tablonun Birincil Anahtarı olarak tanımlar. BENZERSIZ OLACAK VE NOT NULL OLACAK.
 CONSTRAINT "urunlerUnique" UNIQUE("kodu"),
 CONSTRAINT "urunlerCheck" CHECK("miktari" >= 0)
);

/*Neden Doğru Veri Tipi Seçimi Önemli?

Hız (Performans): Veritabanı, daha küçük bir veri tipi (SMALLINT) kullandığınızda veriyi daha hızlı okur ve işler.


Alan Kullanımı (Kaynaklar): Eğer bir sütunun en fazla 1000 olacağını biliyorsanız, 2 milyardan fazla değer alabilen büyük bir sayı tipi (INTEGER) kullanmak disk alanını boşa harcar.


Veri Bütünlüğü: DATE tipine yanlışlıkla bir metin ('fiyat') girmeyi engeller; bu da verilerin tutarlı olmasını sağlar.*/

--DROP TABLE "sema1"."Urunler";

--DROP SCHEMA "sema1";

--DROP DATABASE "SQL_deneme_slayt07";

INSERT INTO "Urunler"
("kodu", "adi", "birimFiyati","uretimTarihi","miktari")
VALUES
('ELO001','TV',1300,'2019-10-30',5);

TRUNCATE TABLE "Urunler"; --urunler tablosundaki tüm verileri siler

ALTER TABLE "Urunler" ADD COLUMN "uretimYeri" VARCHAR(30);
--TABLOYA SUTUN EKLER

ALTER TABLE "Urunler" DROP COLUMN "uretimSaati";
-- SUTUN KALDIRMAK İÇİNDE DROP COLUMN KULLANILIR.

ALTER TABLE "Urunler" ADD "uretimSaati" VARCHAR(30);
--EKLEME AYNI

ALTER TABLE "Urunler" ALTER COLUMN "uretimSaati" TYPE CHAR(20);
-- uretimSaatinin veritipi değiştirilir VARCHAR(30)->CHAR(20)

--SEQUENCE

DROP TABLE "sema1"."Urunler";

CREATE TABLE "sema1"."Urunler"(
"urunNo" SERIAL,
"kodu" CHAR(6) NOT NULL,
"adi" VARCHAR(40) NOT NULL,
"uretimTarihi" DATE DEFAULT '2019-01-01',
"birimFiyati" MONEY,
"miktari" SMALLINT DEFAULT 0,
CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"),
CONSTRAINT "urunlerUnique" UNIQUE("kodu"),
CONSTRAINT "urunlerCheck" CHECK ("miktari" >=0)
);

INSERT INTO "sema1"."Urunler"
("kodu","adi","birimFiyati","uretimTarihi","miktari")
VALUES 
('ELO004','TV',1300,'2019-10-30',5);
--urunNo SERIAL  OLARAK TANIMLANDIGI ICIN EKLEME YAPILIRKEN NO GIRILMEDIGI HALDE BENZERSIZ VE OTOMATIK OALRAK ARTAN BIR DEGER ATAR.



CREATE TABLE "sema1"."Urunler"(
"urunNo" INTEGER,
"kodu" CHAR(6) NOT NULL,
"adi" VARCHAR(40) NOT NULL,
"uretimTarihi" DATE DEFAULT '2019-01-01',
"birimFiyati" MONEY,
"miktari" SMALLINT DEFAULT 0,
CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"),
CONSTRAINT "urunlerUnique" UNIQUE("kodu"),
CONSTRAINT "urunlerCheck" CHECK ("miktari" >=0)
);

ALTER TABLE "sema1"."Urunler" ALTER COLUMN "kodu" DROP NOT NULL;
--urunler tablosundaki kodu sütununun NOT NULL ÖZELLİĞİ KALDIRILDI.

ALTER TABLE "sema1"."Urunler" ALTER "kodu" SET NOT NULL;

INSERT INTO "sema1"."Urunler"
("kodu","adi","birimFiyati","uretimTarihi","miktari","urunNo")
VALUES 
('ELO005','TV',1300,'2019-10-30',5,7);

-- urunNo INTEGER OLARAK TANIMLANDIGINDAN DOLAYI MANUEL EKLEME YAPMAK ZORUNDA KALDIK.

-- TRUNCATE TABLE "sema1"."Urunler"; // TABLO VERİLERİNİ SİLME


--DEFAULT
ALTER TABLE "Urunler" ALTER "uretimTarihi" DROP DEFAULT;

ALTER TABLE "Urunler" ALTER COLUMN "uretimTarihi" SET DEFAULT '2019-01-01';

INSERT INTO "sema1"."Urunler"
("kodu","adi","birimFiyati","miktari","urunNo")
VALUES 
('ELO022','TV',1300,5,21);

--UNIQUE
ALTER TABLE "sema1"."Urunler" DROP CONSTRAINT "urunlerUnique";

ALTER TABLE "sema1"."Urunler" ADD CONSTRAINT "urunlerUnique" UNIQUE ("kodu");

--İKİ ALANLI UNIQUE ORNEGİ

CREATE TABLE "sema1"."Urunler1"(
"urunNo" INTEGER,
"kodu" CHAR(6) NOT NULL,
"adi" VARCHAR(40) NOT NULL,
"uretimTarihi" DATE DEFAULT '2019-01-01',
"birimFiyati" MONEY,
"miktari" SMALLINT DEFAULT 0,
CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"),
CONSTRAINT "urunlerUnique" UNIQUE("kodu","adi"),
CONSTRAINT "urunlerCheck" CHECK ("miktari" >=0)
);

INSERT INTO "sema1"."Urunler1"
("kodu","adi","birimFiyati","miktari","urunNo")
VALUES 
('ELO047','PHONE',1300,5,25);


--CHECK

ALTER TABLE "sema1"."Urunler" DROP CONSTRAINT "urunlerCheck";

ALTER TABLE "sema1"."Urunler" ADD CONSTRAINT "urunlerCheck" CHECK("miktari" >=0);

--PRIMARY KEY

ALTER TABLE "sema1"."Urunler" DROP CONSTRAINT "urunlerPK";

ALTER TABLE "sema1"."Urunler" ADD CONSTRAINT "urunlerPK" PRIMARY KEY ("urunNo");

-- İKİ ALANLI PRİMARY KEY 

CREATE TABLE "sema1"."Urunler1"(
"urunNo" INTEGER,
"kodu" CHAR(6) NOT NULL,
"adi" VARCHAR(40) NOT NULL,
"uretimTarihi" DATE DEFAULT '2019-01-01',
"birimFiyati" MONEY,
"miktari" SMALLINT DEFAULT 0,
CONSTRAINT "urunlerPK2" PRIMARY KEY("adi","kodu"),
CONSTRAINT "urunlerCheck" CHECK ("miktari" >=0)
);

INSERT INTO "sema1"."Urunler1"
("kodu","adi","birimFiyati","miktari","urunNo")
VALUES 
('ELO024','PC',1300,5,21);

ALTER TABLE "sema1"."Urunler1" DROP CONSTRAINT "urunlerPK2";

ALTER TABLE "sema1"."Urunler1" ADD CONSTRAINT "urunlerPK2" PRIMARY KEY ("urunNo","adi");

--FOREIGN KEY













