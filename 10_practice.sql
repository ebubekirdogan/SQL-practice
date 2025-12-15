-- FONKSIYONLAR
CREATE OR REPLACE FUNCTION inch2m(sayiInch REAL)
RETURNS REAL   
AS
$$
BEGIN
RETURN 2.54 * sayiInch/100;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM inch2m(10)

-- IF-ELSE
IF miktar < 100 THEN
    ...
ELSEIF miktar >= 100 AND miktar < 200 THEN
    ...
ELSEIF miktar >= 200 AND miktar < 300 THEN
    ...
ELSE
    ...
END IF;

-- CASE

CASE gunNo
        WHEN 1 THEN gunAd := 'Pazartesi';
        WHEN 2 THEN gunAd := 'Salı';
        WHEN 3 THEN gunAd := 'Çarşamba';
        WHEN 4 THEN gunAd := 'Perşembe';
        WHEN 5 THEN gunAd := 'Cuma';
        WHEN 6 THEN gunAd := 'Cumartesi';
        WHEN 7 THEN gunAd := 'Pazar';
        ELSE gunAd := 'Geçersiz Gün';
    END CASE;
    
---------------------------------------------

-- LOOPS

--EXIT 

CREATE OR REPLACE FUNCTION "basitDongu"()
RETURNS INTEGER
AS $$
DECLARE
    sayi INTEGER := 0;
    toplam INTEGER := 0;
BEGIN
    LOOP
        sayi := sayi + 1;       -- Sayıyı 1 arttır
        toplam := toplam + sayi; -- Toplama ekle
        
        -- Çıkış Şartı: Toplam 50'yi geçerse kaç.
        IF toplam > 50 THEN
            EXIT; 
        END IF;
    END LOOP;
    
    RETURN toplam;
END;
$$ LANGUAGE plpgsql;

-- CONTINUE

CREATE OR REPLACE FUNCTION "continueOrnegi"()
RETURNS INTEGER
AS $$
DECLARE
    toplam INTEGER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        -- Eğer sayı 5 ise, aşağıya inme, döngünün başına dön (Pas geç)
        IF i = 5 THEN
            CONTINUE;
        END IF;

        toplam := toplam + i;
    END LOOP;
    
    RETURN toplam;
END;
$$ LANGUAGE plpgsql;

-- FOR 

CREATE OR REPLACE FUNCTION "faktoriyelHesapla"(girilenSayi INTEGER)
RETURNS INTEGER
AS $$
DECLARE
    sonuc INTEGER := 1;
BEGIN
    -- 1'den girilen sayıya kadar dön
    FOR i IN 1 .. girilenSayi LOOP
        sonuc := sonuc * i;
    END LOOP;
    
    RETURN sonuc;
END;
$$ LANGUAGE plpgsql;

-- WHILE 

CREATE OR REPLACE FUNCTION "whileOrnegi"()
RETURNS INTEGER
AS $$
DECLARE
    sayi INTEGER := 1;
BEGIN
    -- Sayı 10'dan küçük olduğu sürece dön
    WHILE sayi < 10 LOOP
        sayi := sayi * 2;
    END LOOP;
    
    RETURN sayi;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------

-- FONKSIYON ORNEKLERI

CREATE OR REPLACE FUNCTION "fonksiyonTanimlama"(mesaj TEXT, altKarakterSayisi SMALLINT, tekrarSayisi INTEGER)
RETURNS TEXT -- SETOF TEXT, SETOF RECORD diyerek çok sayıda değerin döndürülmesi de mümkündür
AS  
$$
DECLARE
    sonuc TEXT; -- Değişken tanımlama bloğu
BEGIN
    sonuc := '';
    IF tekrarSayisi > 0 THEN
        FOR i IN 1 .. tekrarSayisi LOOP
            sonuc := sonuc || i || '.' || SUBSTRING(mesaj FROM 1 FOR altKarakterSayisi) || E'\r\n';
            -- E: string içerisindeki (E)scape karakterleri için...
        END LOOP;
    END IF;
    RETURN sonuc;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE
SECURITY DEFINER;
    
  --   SUBSTRING(mesaj FROM 1 FOR altKarakterSayisi) girilen mesajın ilk harfinden girilen altkarakter sayısına kadar olan kısmını kesip alır ve tekrar sayısı kadar da yazdırır
  --  E'\r\n' ENTER tuşuna denk gelmektedir.
    
    SELECT * FROM "fonksiyonTanimlama"('Deneme', 2::SMALLINT, 10); -- fonk. çağrısı
/*  1.De
    2.De
    3.De
    4.De
    5.De
    6.De
    7.De
    8.De
    9.De
    10.De */ 

 --------------------------------------------------
 CREATE FUNCTION "kucukOlaniDondur" (INTEGER, INTEGER)
RETURNS INTEGER
AS $$
    if ($_[0] > $_[1]) {
        return $_[1];
    }
    return $_[0];
$$ LANGUAGE "plperl";

-----------------------------------------------------

CREATE OR REPLACE FUNCTION kayitDolanimi()
RETURNS TEXT
AS
$$
DECLARE
    musteri customer%ROWTYPE; -- customer."CustomerID"%TYPE
    sonuc TEXT;
BEGIN
    sonuc := '';
    FOR musteri IN SELECT * FROM customer LOOP
        sonuc := sonuc || musteri."customer_id" || E'\t' || musteri."first_name" || E'\r\n';
    END LOOP;
    RETURN sonuc;
END;
$$
LANGUAGE 'plpgsql';
    
    -- E'\t'  tab tusu (bosluk icin)
    
    -- Verileri "direkt" inceleyemeyiz, çünkü döngü RAM'de çalışır. Tablodaki veriyi RAM'e almak için bir taşıyıcıya (değişkene) ihtiyacımız vardır. %ROWTYPE ise bu taşıyıcıyı oluşturmanın en akıllı ve hatasız yoludur.
    
    -- musteri customer%ROWTYPE; customer tablosunun yapısı neyse, birebir aynısına sahip musteri adında bir değişken (struct) oluştur. Eklemeler olduğunda aynen      kopyalamaya devam eder.
    --
    -- tüm veriler tek tek alınır ve de incelenir
    -------------------------------------------------------------
    CREATE OR REPLACE FUNCTION personelAra(personelNo INT)
RETURNS TABLE(numara INT, adi VARCHAR(40), soyadi VARCHAR(40)) 
AS 
$$
BEGIN
    RETURN QUERY SELECT "staff_id", "first_name", "last_name" FROM staff
                 WHERE "staff_id" = personelNo;
END;
$$
LANGUAGE "plpgsql";

SELECT * FROM "personelAra"(1);

-- Sonuç: 1 numaralı çalışanın bilgileri tablo formatında gelecektir.
    
    --------------------------------------------------------------
    
CREATE OR REPLACE FUNCTION public.odemetoplami(personelno INTEGER)
RETURNS TEXT
LANGUAGE "plpgsql"
AS
$$
DECLARE
    -- --- DEĞİŞKEN TANIMLAMA BLOĞU ---

    personel RECORD;
    -- AÇIKLAMA: 'RECORD' veri tipi girilen veriye göre şekillenir).
    -- Birazdan içine bir sorgu sonucu atacağız ve bu değişken, o sorgudan gelen
    -- sütunların (ad, soyad, numara) şeklini otomatik olarak alacak.

    miktar NUMERIC;
    -- AÇIKLAMA: Personelin topladığı parayı tutacak sayısal kutu.
    -- Küsüratlı para birimi olabileceği için 'NUMERIC' tipi seçildi.

BEGIN
    -- --- İŞLEM (MANTIK) BLOĞU ---

    personel := personelAra(personelNo);
    -- AÇIKLAMA (FONKSİYON ÇAĞIRMA): 
    -- Burada işi kendimiz yapmıyoruz. Bir örnek önce yazdığımız 'personelAra' fonksiyonunu "taşeron" olarak çağırıyoruz.
    -- O fonksiyon gidip personelin adını soyadını buluyor, sonucu getirip bizim 'personel' değişkenimize kopyalıyor.

    miktar := (SELECT SUM(amount) FROM payment WHERE staff_id = personelNo);
    -- AÇIKLAMA (HESAPLAMA):
    -- 'payment' (ödeme) tablosuna gidiyoruz.
    -- Dışarıdan girilen 'personelNo'ya sahip kişinin kasasındaki tüm paraları (amount) topluyoruz (SUM).
    -- Çıkan sonucu 'miktar' değişkenine atıyoruz.

    RETURN personel."numara" || E'\t' || personel."adi" || E'\t' || miktar;
    -- AÇIKLAMA (BİRLEŞTİRME VE SONUÇ):
    -- 1. 'personel' değişkeninden Numarayı al.
    -- 2. 'personel' değişkeninden Adı al.
    -- 3. Hesapladığımız 'miktar'ı al.
    -- 4. Hepsini '||' işaretiyle birbirine yapıştır.
    -- 5. Aralarına E'\t' (TAB boşluğu) koy ki okunaklı olsun.
    -- 6. Oluşan tek satırlık metni dışarı fırlat.
END
$$;
    
    -------------------------------------------------

CREATE OR REPLACE FUNCTION inch2cm (sayiInch REAL, OUT sayiCM REAL)
-- AÇIKLAMA (GİRİŞ/ÇIKIŞ):
-- 1. 'sayiInch REAL': Bu normal bir GİRİŞ (IN) parametresidir. Kullanıcıdan alınır.
-- 2. 'OUT sayiCM REAL': İşte sihir burada! 'OUT' kelimesi şu demek:
--    "Bu değişkeni ben sana veriyorum ama içi boş. Sen hesaplamanı yapıp sonucu buna yükleyeceksin."
--    Bu yöntemi kullanınca aşağıda ayrıca 'RETURNS ...' yazmamıza gerek kalmaz.
--  sayiInch önüne IN de yazılabilir. default değer IN dir.
AS
$$
BEGIN
    -- --- İŞLEM BLOĞU ---
    
    sayiCM := 2.54 * sayiInch;
    -- AÇIKLAMA:
    -- Kullanıcıdan gelen inç değerini 2.54 ile çarpıyoruz.
    -- Sonucu direkt olarak yukarıda tanımladığımız 'OUT' parametresine (sayiCM) atıyoruz.
    -- Ayrıca 'RETURN sayiCM;' dememize gerek YOK. 
    -- Fonksiyon bittiği an, 'sayiCM'nin içindeki değer otomatik olarak dışarı fırlatılır.

END;
$$
LANGUAGE "plpgsql";
    
    
     ---------------------------------------------------------------------
     -- SAKLI YORDAMLAR (PROCEDURE)
     
     CREATE TABLE "public"."musteriodemeleri" (
     "id" BIGINT,
     "musteriadi" VARCHAR(50),
     "musterisoyadi" VARCHAR(50),
     "magazayoneticisiadi" VARCHAR(50),
     "magazayoneticisisoyadi" VARCHAR(50),
     "toplamodeme" DOUBLE PRECISION,
     "tarih" TIMESTAMP);
     
     CREATE SEQUENCE sequence1;
     
CREATE OR REPLACE PROCEDURE public.musteriodemelerinihesapla1(storeid SMALLINT)
-- AÇIKLAMA (TANIM):
-- Bu bir 'PROCEDURE' (Saklı Yordam) dır. Fonksiyondan farkı, 'CALL' komutuyla çağrılmasıdır.
-- Parametre olarak 'storeid' (Mağaza Numarası) alır.
-- Amacı: O mağazadaki müşterilerin ne kadar harcama yaptığını hesaplayıp, rapor tablosuna kaydetmektir.

LANGUAGE plpgsql
AS
$$
DECLARE
    -- --- DEĞİŞKEN TANIMLAMA BLOĞU ---

    customerrow customer%ROWTYPE;
    -- AÇIKLAMA: 'customer' (müşteri) tablosunun bir satırının kopyasını tutacak değişken.
    -- Döngü sırasında sıradaki müşterinin tüm bilgileri (ID, Ad, Soyad) buraya yüklenecek.

    yoneticiid smallint;
    -- AÇIKLAMA: O mağazanın müdürünün ID numarasını tutacak basit bir sayı değişkeni.

    yonetici record;
    -- AÇIKLAMA: Müdürün detaylı bilgilerini (Adı, Soyadı) tutacak değişken.
    -- 'personelAra' fonksiyonundan gelen sonuç tablosunun şeklini alacak.

    odemetoplami double precision;
    -- AÇIKLAMA: O anki müşterinin toplam harcamasını tutacak virgüllü sayı değişkeni.

BEGIN
    -- --- 1. ADIM: YÖNETİCİYİ BULMA ---
    
    -- Önce girilen mağaza numarasını (storeid) kullanarak, o mağazanın müdürü kimmiş onu buluyoruz.
    yoneticiid := (select manager_staff_id from public.store where store_id = storeid);              
    -- store_id tablo içerisinde mevcut.
    
    -- Bulduğumuz yönetici ID'sini, daha önce yazdığımız 'personelAra' fonksiyonuna gönderiyoruz.
    -- O fonksiyon bize müdürün adını ve soyadını getirip 'yonetici' değişkenine koyuyor.
    yonetici := personelAra(yoneticiid);


    -- --- 2. ADIM: MÜŞTERİ DÖNGÜSÜ ---

    -- 'customer' tablosuna gidiyoruz. Sadece parametre olarak gelen mağazanın (storeid) müşterilerini seçiyoruz.
    -- Bu müşterileri tek tek (FOR döngüsüyle) geziyoruz.
    -- Her turda, sıradaki müşterinin bilgileri 'customerrow' değişkenine yükleniyor.
    FOR customerrow IN SELECT * FROM customer where store_id = storeid order by customer_id
        LOOP
            
            -- --- 3. ADIM: HESAPLAMA ---
            
            -- Sıradaki müşterinin (customerrow.customer_id) 'payment' tablosundaki tüm harcamalarını topluyoruz (SUM).
            -- Sonucu 'odemetoplami' değişkenine atıyoruz.
            odemetoplami := (SELECT SUM(amount) FROM payment WHERE customer_id = customerrow.customer_id);
            
            
            -- --- 4. ADIM: RAPORLAMA (KAYDETME) ---
            
            -- Hesapladığımız tüm bu verileri 'musteriodemeleri' adlı rapor tablosuna EKLE (INSERT).
            INSERT INTO musteriodemeleri(
                id, 
                musteriadi, 
                musterisoyadi, 
                magazayoneticisiadi, 
                magazayoneticisisoyadi, 
                toplamodeme, 
                tarih
            )
            VALUES (
                NEXTVAL('public.sequence1'), -- ID için sıradaki numarayı otomatik üret (Otomatik Sayaç).
                customerrow.first_name,      -- Müşterinin Adı (Döngüden geldi).
                customerrow.last_name,       -- Müşterinin Soyadı (Döngüden geldi).
                yonetici.adi,                -- Müdürün Adı (Yukarıda fonksiyondan bulmuştuk).
                yonetici.soyadi,             -- Müdürün Soyadı.
                odemetoplami,                -- Hesapladığımız para.
                current_timestamp            -- İşlemin yapıldığı tam şu anki tarih ve saat.
            );
            
        END LOOP; -- Sonraki müşteriye geç.

END;
$$;
     
     
     CALL musteriodemelerinihesapla1(1::SMALLINT); 
     -- CALL İLE ÇAĞRILIRLAR
    --------------------------------------------------------------------------
    
    -- İMLEÇ (İŞARETÇİ)
    
    
    CREATE OR REPLACE FUNCTION filmAra (yapimYili INTEGER, filmAdi TEXT)
RETURNS TEXT
AS
$$
DECLARE
    -- --- DEĞİŞKENLER ---
    
    filmAdlari TEXT DEFAULT ''; 
    -- Sonuçları (bulunan film isimlerini) biriktireceğimiz metin kutusu.

    film RECORD;
    -- Veritabanından o an çektiğimiz tek bir satırı tutacak geçici değişken.

    -- --- CURSOR (İMLEÇ) TANIMLAMA ---
    -- Burada sorguyu çalıştırıp veriyi RAM'e yüklemiyoruz!
    -- Sadece "Benim şu sorguyla bir işim olacak" diyoruz
    filmImleci CURSOR (yapimYili INTEGER) FOR 
        SELECT * FROM film WHERE release_year = yapimYili;

BEGIN
    -- --- 1. İMLECİ AÇ (OPEN) ---
    -- Veritabanı sorguyu hazırlar ama henüz veri çekmez.
    -- İmleci, parametre olarak gelen yıl (yapimYili) ile açıyoruz.
    OPEN filmImleci (yapimYili);

    LOOP
        -- --- 2. VERİYİ ÇEK (FETCH) ---
        -- "Bana sıradaki satırı getir ve 'film' değişkeninin içine koy."
        FETCH filmImleci INTO film;

        -- --- 3. BİTİŞ KONTROLÜ ---
        -- Eğer çekilecek satır kalmadıysa (NOT FOUND), döngüden çık.
        EXIT WHEN NOT FOUND;

        -- --- 4. FİLTRELEME VE İŞLEM ---
        -- Gelen filmin adı, aradığımız kelimeyle başlıyor mu? (Manuel kontrol)
        -- (LIKE operatörü ve || birleştirme işareti kullanılıyor)
        IF film.title LIKE filmAdi || '%' THEN
        
    --    Burada String Birleştirme (||) yapılıyor.

    --   Senin Girdin (filmAdi): 'T'

    --   Birleştirme: 'T' + '%' = 'T%'

    --   Anlamı: "Filmin adı T harfi ile başlıyor mu?"

    --   Eğer kullanıcı 'Spider' girseydi, kod 'Spider%' olacak ve "Spider-Man", "Spider-Woman" gibi Spider ile başlayan her şeyi bulacaktı.(Film adı tam            hatırlanamadıysa diye )
        
        
            -- Eğer uyuyorsa, listemize ekle ve alt satıra geç.
            filmAdlari := filmAdlari || film.title || ':' || film.release_year || E'\r\n';
        END IF;

    END LOOP;

    -- --- 5. İMLECİ KAPAT (CLOSE) ---
    -- İşimiz bitti, veritabanına "Kaynakları serbest bırakabilirsin" diyoruz.
    CLOSE filmImleci;

    RETURN filmAdlari;
END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM filmAra(2006, 'T'); -- fonk. çağrısı yapılır.
    
    ----------------------------------------------------------------------------------------------
    
    -- TETİKLEYİCİLER (TRİGGER)
    
    CREATE TABLE "public"."UrunDegisikligiIzle" (
    "kayitNo" serial,               -- Otomatik artan numara (1, 2, 3...)
    "urunNo" SMALLINT NOT NULL,     -- Hangi ürün değişti?
    "eskiBirimFiyat" REAL NOT NULL, -- Fiyat eskiden kaçtı?
    "yeniBirimFiyat" REAL NOT NULL, -- Şimdi kaç oldu?
    "degisiklikTarihi" TIMESTAMP NOT NULL, -- Ne zaman oldu?
    CONSTRAINT "PK" PRIMARY KEY ("kayitNo")
);
    
    CREATE OR REPLACE FUNCTION "urunDegisikligiTR1"()
RETURNS TRIGGER -- Dikkat: Bu fonksiyon normal değer değil, 'TRIGGER' döner.
AS
$$
BEGIN
    -- KONTROL: Gerçekten fiyat değişmiş mi? 
    -- (Bazen kullanıcı fiyatı 10 iken yine 10 olarak günceller, onu kaydetmeye gerek yok)
    IF NEW."UnitPrice" <> OLD."UnitPrice" THEN 
    -- <> operatoru; eşit değildir anlamına gelmektedir.
        
        -- KAYIT: Değişikliği yakaladık! Hemen (Log) yazalım.
        INSERT INTO "UrunDegisikligiIzle"(
            "urunNo", 
            "eskiBirimFiyat", 
            "yeniBirimFiyat", 
            "degisiklikTarihi"
        )
        VALUES(
            OLD."ProductID",              -- Ürünün ID'si (Değişmediği için OLD veya NEW fark etmez)
            OLD."UnitPrice",              -- ESKİ Fiyatı buraya al.
            NEW."UnitPrice",              -- YENİ Fiyatı buraya al.
            CURRENT_TIMESTAMP::TIMESTAMP  -- Şu anki zamanı bas.
        );
    END IF;

    -- ONAY: İşlem tamam, yeni veriyi (NEW) veritabanına yazabilirsin.
    -- Eğer burada 'RETURN NULL' deseydik, güncelleme işlemi iptal olurdu!
    RETURN NEW;
END;
$$
LANGUAGE "plpgsql";
    
    
CREATE TRIGGER "urunBirimFiyatDegistiginde" -- Tetikleyicinin adı
BEFORE UPDATE ON "products"  -- NE ZAMAN? -> Products tablosunda güncelleme olmadan hemen ÖNCE.
FOR EACH ROW                 -- NASIL? -> Güncellenen HER BİR SATIR için tek tek çalıştır.
EXECUTE PROCEDURE "urunDegisikligiTR1"(); -- HANGİ FONKSİYONU? -> Yazdığımız tuzağı çalıştır.
    
-- 4 Numaralı ürünün fiyatını 100 yapıyoruz.
UPDATE "products"
SET "UnitPrice" = 100
WHERE "ProductID" = 4;
    
SELECT * FROM "UrunDegisikligiIzle"; -- Kayıtlar gelecek
    
    
    --------------------------------------------------------------------------------------------------
    -- BEFORE İFADESİ
    
CREATE OR REPLACE FUNCTION "kayitEkleTR1"()
RETURNS TRIGGER
AS
$$
BEGIN
    -- 1. DÜZENLEME (Otomatik Düzeltme)
    -- Şirket adını al, büyük harfe çevir ve tekrar yerine koy.
    NEW."CompanyName" := UPPER(NEW."CompanyName");
    
    -- Kişi adının sağ/sol boşluklarını sil.
    NEW."ContactName" := TRIM(NEW."ContactName");

    -- 2. DENETİM (Validation)
    -- Eğer Şehir (City) alanı boşsa (NULL)...
    IF NEW."City" IS NULL THEN
        -- ...İşlemi durdur ve kullanıcıya şu hatayı fırlat:
        RAISE EXCEPTION 'Sehir alanı boş olamaz!';
    END IF;

    -- Her şey yolundaysa, düzeltilmiş yeni veriyi (NEW) içeri al.
    RETURN NEW;
END;
$$
LANGUAGE "plpgsql";
    
    CREATE TRIGGER "kayitKontrol"
    BEFORE INSERT OR UPDATE ON "customers" -- Hem Ekleme hem Güncelleme öncesi çalışsın
    FOR EACH ROW
    EXECUTE PROCEDURE "kayitEkleTR1"();
    
    INSERT INTO "customers" ("CustomerID", "CompanyName", "ContactName")
    VALUES ('999', 'abc ltd.', '  Ayşe Yalın  ');
    -- City yazılmadığı için hata alınacak
    
    INSERT INTO "customers" ("CustomerID", "CompanyName", "ContactName", "City")
    VALUES ('999', 'abc ltd.', '  Ayşe Yalın  ', 'Sakarya');
    -- Kayıt eklenecek
    
    -------------------------------------------------------
    --TETİKLEYİCİLERİ YÖNETME
    
    ALTER TABLE "products" DISABLE TRIGGER "urunBirimFiyatDegistiginde"; 
    --Artık fiyat değişse de log tutmaz.
    
    
    ALTER TABLE "products" ENABLE TRIGGER "urunBirimFiyatDegistiginde";
    -- Tetikleyici aktif hale getirilir
    
    ALTER TABLE "products" DISABLE TRIGGER ALL;
    -- Tüm tetikleyiciler pasif hale getirilir.
    
     ALTER TABLE "products" ENABLE TRIGGER ALL;
    -- Tüm tetikleyiciler aktif hale getirilir.
    
    DROP TRIGGER "urunBirimFiyatDegistiginde" ON "products";
    -- tetikleyici tamamen kaldırılır. geri getirmek için yeniden yazılması gerekebilir.
    ----------------------------------------------------------------------------------------
    
    -- HAZIR FONKSİYONLAR
    
    SELECT CURRENT_DATE; -- MEVCUT TARİHİ SEÇER
    
    SELECT CURRENT_TIME; -- MEVCUT ZAMANI SEÇER 
    
    SELECT CURRENT_TIMESTAMP; -- MEVCUT ZAMAN VE TARİH AYNI ANDA SEÇİLİR
    
    SELECT NOW(); -- TIMESTAMP ILE AYNI
    
    SELECT AGE(TIMESTAMP '2018-04-10', TIMESTAMP '1957-06-13'); -- ARALIKTAKI ZAMANI DONDURUR.
    
    SELECT AGE(TIMESTAMP '2018-10-07 23:00:01'); --  VERİLEN VAKİTTEN GÜNÜMÜZE KADAR GEÇEN ZAMANI DÖNDÜRÜR
    
    SELECT AGE(TIMESTAMP '2000-10-07'); -- 19 years 1 mon 22 days (YAŞ HESAPLAMA)
    
   -- DATE_PART() ve EXTRACT() fonksiyonları, tarih/zaman'dan ya da zaman diliminden(interval) istenen bölümü almak için kullanılır: 
   
   SELECT DATE_PART('years', AGE(TIMESTAMP '2000-10-07'));
   
   SELECT DATE_PART('day', INTERVAL '2 years 5 months 4 days'); 
   
   SELECT EXTRACT(DAY FROM INTERVAL '2 years 5 months 4 days'); 
   
   SELECT EXTRACT(HOUR FROM TIMESTAMP '2018-12-10 19:27:45');
   
   SELECT DATE_TRUNC('minute', TIMESTAMP '2018-10-07 23:05:40'); -- 2018-10-07 23:05:00 (Tarih-zaman bilgisini istenilen hassasiyette göstermek için kullanılır.)
   
   SELECT JUSTIFY_DAYS(INTERVAL '51 days');  -- 1 ay 21 gün(30 günlük periyotlara bölerek gösterir)
   
   SELECT JUSTIFY_HOURS(INTERVAL '27 hours'); -- 1 gün 03:00:00 (24saatlik periyotlara bölerek ifade eder)
   
   SELECT JUSTIFY_INTERVAL(INTERVAL '1 mon -1 hour') -- 29 gün 23:00:00 (Zaman aralığını hem JUSTIFY_DAYS hem de JUSTIFY_HOURS kullanarak işaretleri de dikkate alarak ifade et.)
   
   -- TO_CHAR : tarih ev zaman biçimlendirme
   
   SELECT TO_CHAR(CURRENT_TIMESTAMP, 'HH24:MI:SS:MS'); -- HH12, MS Milisecond, US microsecond
   
   SELECT TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY');   -- YYYY year (4 basamak), YY, TZ	time zone
   
   -- örnek film kiralama sürelerinin bulunması
   
SELECT 
    customer_id,                              -- 1. Sütun: Müşteri Numarası
    to_char(rental_date, 'DD/MM/YYYY'),       -- 2. Sütun: Kiralama Tarihi (Güzelleştirilmiş)
    return_date,                              -- 3. Sütun: İade Tarihi
    age(return_date, rental_date)             -- 4. Sütun: Elde Tutma Süresi (Fark)
FROM rental
WHERE return_date IS NOT NULL                 -- Filtre: Henüz iade edilmemişleri gizle
ORDER BY 3 DESC                               -- Sıralama: 3. sıradaki sütuna göre!(yani return_date'e göre)
   
   
   
   
   
   
   
   
   
   
   
    
    
    
    
  