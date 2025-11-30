CREATE SEQUENCE "sayac";

CREATE TABLE "Urunler" (
    "urunNo" INTEGER DEFAULT NEXTVAL('sayac'),
    "kodu" CHAR(6) NOT NULL,
    "adi" VARCHAR(40) NOT NULL,
    "uretimTarihi" DATE DEFAULT '2019-01-01',
    "birimFiyati" MONEY,
    "miktari" SMALLINT DEFAULT 0,
    CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"),
    CONSTRAINT "urunlerUnique" UNIQUE("kodu"),
    CONSTRAINT "urunlerCheck" CHECK("miktari" >= 0)
);

INSERT INTO "Urunler"
("kodu", "adi", "birimFiyati", "uretimTarihi", "miktari")
VALUES
('EL0005', 'TV', 1300, '2019-10-30', 5);

-- FOREIGN KEY

CREATE TABLE "UrunSinifi" (
    "sinifNo" SERIAL,
    "adi" VARCHAR(30) NOT NULL,
	CONSTRAINT "urunSinifiPK" PRIMARY KEY("sinifNo")
);

CREATE TABLE "Urunler" (
	"urunNo" INTEGER DEFAULT NEXTVAL('sayac'),
	"kodu" CHAR(6) NOT NULL,
	"adi" VARCHAR(40) NOT NULL,
	"sinifi" INTEGER NOT NULL, 
	"uretimTarihi" DATE DEFAULT '2019-01-01',
	"birimFiyati" MONEY,
	"miktari" SMALLINT DEFAULT 0,
	CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"),
	CONSTRAINT "urunlerUnique" UNIQUE("kodu"),
	CONSTRAINT "urunlerCheck" CHECK("miktari" >= 0),
	CONSTRAINT "urunSinifiFK1" FOREIGN KEY("sinifi") REFERENCES "UrunSinifi"("sinifNo")
);
--Bu ifade yukarıdaki ile aynıdır. ON DELETE ve ON UPDATE durumunda ne yapılacağı belirtilmediğinde varsayılan olarak NO ACTION olur.
CREATE TABLE "Urunler" (
	"urunNo" SERIAL,
	"kodu" CHAR(6) NOT NULL,
	"adi" VARCHAR(40) NOT NULL,
	"sinifi" INTEGER NOT NULL, 
	"uretimTarihi" DATE DEFAULT '2019-01-01',
	"birimFiyati" MONEY,
	"miktari" SMALLINT DEFAULT 0,
	CONSTRAINT "urunlerPK" PRIMARY KEY("urunNo"),
	CONSTRAINT "urunlerUnique" UNIQUE("kodu"),
	CONSTRAINT "urunlerCheck" CHECK("miktari" >= 0),
	CONSTRAINT "urunSinifiFK1" FOREIGN KEY("sinifi") REFERENCES "UrunSinifi"("sinifNo") 
	ON DELETE NO ACTION 
	ON UPDATE NO ACTION
);
-- İlk olarak foreignkey urunler tablosu -> bagımlı
-- References UrunSinifi -> Ana Tablo

-- ON DELETE NO ACTION -> Anlamı: Yabancı anahtar ile bağlı olan ana tablodaki (bu örnekte UrunSinifi) bir kaydı silmeye çalıştığınızda, bağımlı tabloda (bu örnekte Urunler) o kaydı kullanan satırlar varsa, silme işlemi derhal başarısız olur ve engellenir.İşlevi: Veritabanı, önce Urunler tablosundaki bağımlı kayıtların silinmesini veya güncellenmesini ister. Aksi takdirde silme işlemine izin vermez.

-- ON UPDATE NO ACTION -> Ana tablodaki (UrunSinifi) birincil anahtar sütunundaki (bu örnekte sinifNo) değeri güncellemeye çalıştığınızda, bağımlı tabloda (Urunler) o değeri kullanan satırlar varsa, güncelleme işlemi derhal başarısız olur ve engellenir.İşlevi: Tıpkı ON DELETE gibi, bu kısıtlama da ana anahtarın değerini, ona bağımlı olan kayıtlar mevcut olduğu sürece değiştirmenize izin vermez.


ALTER TABLE "Urunler" DROP CONSTRAINT "urunSinifiFK1";

ALTER TABLE "Urunler" ADD CONSTRAINT "urunSinifiFK1" FOREIGN KEY("sinifi") REFERENCES "UrunSinifi"("sinifNo")
ON DELETE NO ACTION
ON UPDATE NO ACTION;;
--SON IKI SATIR OLMASA DA OLUR. STANDART DROP-ADD İŞLEMLERİ

ALTER TABLE "Urunler"
ADD CONSTRAINT "urunSinifiFK1" FOREIGN KEY("sinifi")
REFERENCES "UrunSinifi"("sinifNo")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

-- ON DELETE RESTRICT -> Anlamı: Eğer UrunSinifi (Ana Tablo) tablosundaki bir sinifNo değerini silmeye çalışırsanız ve bu sinifNo değerini Urunler (Bağımlı Tablo) tablosundaki herhangi bir kayıt kullanıyorsa, silme işlemi derhal engellenir ve bir hata mesajı ile başarısız olur.Örnek: Eğer "Elektronik" sınıfını (sinifNo=5) silmek isterseniz, ancak "TV" ürünü hala 5 numaralı sınıfı kullanıyorsa, veritabanı silme işlemini reddeder.

-- ON UPDATE RESTRICT -> Anlamı: Eğer UrunSinifi (Ana Tablo) tablosundaki bir sinifNo değerini güncellemeye (değiştirmeye) çalışırsanız ve bu eski sinifNo değerini Urunler (Bağımlı Tablo) tablosundaki herhangi bir kayıt kullanıyorsa, güncelleme işlemi derhal engellenir ve bir hata mesajı ile başarısız olur.Örnek: Eğer "Elektronik" sınıfının numarasını 5'ten 99'a değiştirmek isterseniz, ancak "TV" ürünü hala 5 numaralı sınıfı kullanıyorsa, veritabanı güncelleme işlemini reddeder.

ALTER TABLE "Urunler"
ADD CONSTRAINT "urunSinifiFK1" FOREIGN KEY("sinifi")
REFERENCES "UrunSinifi"("sinifNo")
ON DELETE CASCADE
ON UPDATE CASCADE;
 -- ON DELETE CASCADE -> Ne Yapar: Eğer UrunSinifi (Ana Tablo) tablosundaki bir sinifNo değerine sahip kayıt silinirse, bu sinifNo değerini kullanan Urunler (Bağımlı Tablo) tablosundaki tüm kayıtlar da otomatik olarak silinir.

-- ON UPDATE CASCADE -> Eğer UrunSinifi (Ana Tablo) tablosundaki birincil anahtar olan sinifNo değeri güncellenirse (değiştirilirse), bu yeni değer, Urunler (Bağımlı Tablo) tablosundaki ilgili tüm kayıtların yabancı anahtar sütunlarına ("sinifi") otomatik olarak kopyalanır ve güncellenir.


