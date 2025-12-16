SET search_path TO public;

SELECT * FROM products WHERE UnitPrice < 10;

-- Bu tekli sorgudur. Çoklu sorguda ise örneğin UnitPrice spesifik bir satıcının sattığı tüm ürünlerden daha düşük olanını getir deriz. ve o satıcıya ait tüm ürünleri karşılaştırabilir.

-- WHERE İLE TEK DEĞER DÖNDÜREN SORGULAR

SELECT AVG("UnitPrice") FROM "public"."products";


SELECT "ProductID", "UnitPrice" FROM "public"."products"
WHERE "UnitPrice" < (SELECT AVG("UnitPrice") FROM "public"."products");

SELECT "ProductID" FROM "products" WHERE "ProductName" = 'Y Z Bilgisayar';

SELECT DISTINCT "public"."customers"."CustomerID",
  "public"."customers"."CompanyName",
  "public"."customers"."ContactName"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID"
INNER JOIN "order_details" ON "order_details"."OrderID" = "orders"."OrderID"
WHERE "order_details"."ProductID" =
  (SELECT "ProductID" FROM "products" WHERE "ProductName" = 'Y Z Bilgisayar')
ORDER BY "public"."customers"."CustomerID";

-------------------------------------------------------------------------------------------------------------------------
-- WHERE İLE ÇOKLU DEĞER DÖNDÜREN SORGULAR
-- IN; gereksinime uyan sorgu var diye kontrol eder.

SELECT "SupplierID" FROM "products" WHERE "UnitPrice" > 18;

SELECT * FROM "suppliers"
WHERE "SupplierID" IN
  (SELECT "SupplierID" FROM "products" WHERE "UnitPrice" > 18);
  
 -- birinci ifade fiyatı 18den fazla ürünü olan tedarikçilerin ID lerini getirir
 -- 2. sorgu ise >18 koşuluunu sağlayan tedarikçilerin ID leri alarak suppliers tablosuna gider ve tüm bilgileirni çeker.
 
 -------------------------------------------------------------

SELECT "ProductID" FROM "products" WHERE "ProductName" LIKE 'A%'; 
 
-- Tek sorgu,sadece ProductID leri getirir

SELECT DISTINCT "public"."customers"."CustomerID",
  "public"."customers"."CompanyName",
  "public"."customers"."ContactName"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID"
INNER JOIN "order_details" ON "order_details"."OrderID" = "orders"."OrderID"
WHERE "order_details"."ProductID" IN
  (SELECT "ProductID" FROM "products" WHERE "ProductName" LIKE 'A%');
  
  -------------------------------------------------------------
 UPDATE "orders"
SET "ShipCountry" = 'Mexico'
WHERE "CustomerID" IN
(SELECT "CustomerID" FROM "customers" WHERE "Country" = 'Mexico');
  
  -------------------------------------------------------------
  DELETE FROM "products"
  WHERE "SupplierID" IN
  (SELECT "SupplierID" FROM "suppliers" WHERE "Country" = 'USA');
  
  ------------------------------------------------------------- 
  
 -- ANY ILE ÇOKLU SORGU
 
 SELECT * FROM "products"
WHERE "UnitPrice" IN
(
    SELECT "UnitPrice"
    FROM "suppliers"
    INNER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);
-- SELECT * FROM "products" ; Bu sorgu, UnitPrice değeri, 'Tokyo Traders' adlı tedarikçinin sağladığı ürünlerin fiyat listesi içerisinde bulunan tüm ürünleri getirir.
SELECT * FROM "products"
WHERE "UnitPrice" = ANY
(
    SELECT "UnitPrice"
    FROM "suppliers"
    INNER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);
  
  -- bu iki örnekten görüleceği gibi IN ile =ANY aynı işi yapmaktadır
  
  SELECT * FROM "products"
WHERE "UnitPrice" < ANY
(
    SELECT "UnitPrice"
    FROM "suppliers"
    INNER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);
  
  -- “UnitPrice, Tokyo Traders’ın ürünlerinden EN AZ BİR TANESİNDEN küçük olsun”
  
  SELECT * FROM "products"
WHERE "UnitPrice" > ANY 
(
    SELECT "UnitPrice" 
    FROM "suppliers"
    INNER JOIN "products" 
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);

-- Tokyo Traders firmasının sattığı ürünlerden en az bir tanesinden DAHA PAHALI olan tüm ürünleri listeler.

-------------------------------------------------------------------------------------

-- ALL ILE ÇOKLU SORGU

SELECT * FROM "products"
WHERE "UnitPrice" < ALL
(
    SELECT "UnitPrice"
    FROM "suppliers"
    INNER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);

-- Tokyo Traders firmasının sattığı ürünlerin TAMAMINDAN daha ucuz olan tüm ürünleri listeler.

SELECT * FROM "products"
WHERE "UnitPrice" > ALL 
(
    SELECT "UnitPrice" 
    FROM "suppliers"
    INNER JOIN "products" 
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);
  
  -- Tokyo Traders firmasının sattığı ürünlerin TAMAMINDAN daha pahalı olan tüm ürünleri listeler.
  
  ----------------------------------------------------------------------------------------------
  
  -- HAVING ILE ÇOKLU SORGU
  
  -- WHERE ifadesinin aksine, HAVING içinde toplu fonksiyonlar (SUM, AVG, MAX, vb.) kullanılabilir.
  
  SELECT AVG("UnitsInStock") FROM "products";
  
 SELECT "SupplierID", SUM("UnitsInStock") AS "stoktaki ToplamUrunSayisi"
FROM "products"
GROUP BY "SupplierID"
HAVING SUM("UnitsInStock") < (SELECT AVG("UnitsInStock") FROM "products"); 
  
  SELECT MAX("Quantity") FROM "order_details";
  
  SELECT "ProductID", SUM("Quantity")
FROM "order_details"
GROUP BY "ProductID"
HAVING SUM("Quantity") > (SELECT MAX("Quantity") FROM "order_details");
 
 -- Bu kısım, tüm siparişler genelinde her bir ürünün toplamda kaç adet satıldığını hesaplar."Toplamda Satılan Miktar (SUM("Quantity"))", "Tek Bir Siparişteki En Yüksek Satış Miktarından (MAX("Quantity"))" daha büyük mü?
 
 
 ---------------------------------------------------------------------------
 
 -- SATIR ICI (INLINE) ALT SORGU KULLANIMI 
 
 SELECT
  "ProductName",
  "UnitsInStock",
  (SELECT MAX("UnitsInStock") FROM "products") AS "enBuyukDeger" --> BU SORGU TEK ALAN VE TEK SUTUN DONDURUR.
FROM "products";
 
 ---------------------------------------------------------------------------
 
 -- ILINTILI SORGU
 
SELECT "ProductName", "UnitPrice" FROM "products" AS "urunler1"
WHERE "urunler1"."UnitPrice" >
(
  SELECT AVG("UnitPrice") FROM "products" AS "urunler2"
  WHERE "urunler1"."SupplierID" = "urunler2"."SupplierID"
);

-- EXIST IFADESI ILE BASARIMI COK DAHA IYIDIR

SELECT "CustomerID", "CompanyName", "ContactName"
FROM "customers"
WHERE EXISTS
  (SELECT * FROM "orders" WHERE "customers"."CustomerID" = "orders"."CustomerID");

-- EXIST TUM SATIRLARDA SORGU YAPMAZ EGER BIR MUSTERI SIPARIS VERMISSE O MUSTERI ICIN SORGUYA DEVAM ETMEZ.

-- AYNI SONUC FARKLI BULGULAR ILE DE BULUNABILIR ANCAK DAHA YAVAS OLUR.
SELECT "CustomerID", "CompanyName", "ContactName"
FROM "customers"
WHERE "CustomerID" =
  (SELECT DISTINCT "CustomerID" FROM "orders" WHERE "orders"."CustomerID" = "customers"."CustomerID");

SELECT "CustomerID", "CompanyName", "ContactName"
FROM "customers"
WHERE "CustomerID" IN
  (SELECT "CustomerID" FROM "orders" WHERE "orders"."CustomerID" = "customers"."CustomerID");

SELECT DISTINCT "public"."customers"."CompanyName",
  "public"."customers"."ContactName"
FROM "orders" 
INNER JOIN "customers"  ON "orders"."CustomerID" = "customers"."CustomerID";

-----

SELECT "CustomerID", "CompanyName", "ContactName"
FROM "customers"
WHERE NOT EXISTS
 (SELECT * FROM "orders" WHERE "customers"."CustomerID" = "orders"."CustomerID");

-- SIPARISI OLMAYAN MUSTERILERI LISTELER -> BURADA DA EĞER SİPARİŞİ OLAN MÜŞTERİ BULURSA TRUE DONDURUR VE O MÜŞTERİ İÇİN SORGUYU BİTİRİR(HIZLIDIR)


 ---------------------------------------------------------------------------

-- UNION VE UNION ALL (KUME BIRLESIMI)

SELECT "CompanyName", "Country" FROM "customers"
UNION 
SELECT "CompanyName", "Country" FROM "suppliers"
ORDER BY 1;

-- ORDER BY 1 ILE COMPANYNAME'E GORE 2 ILE DE COUNTRY'E GORE SIRALAMA YAPAR

SELECT "CompanyName", "Country" FROM "customers"
UNION ALL
SELECT "CompanyName", "Country" FROM "suppliers"
ORDER BY 1;

--UNION ALL ILE TEKRAR EDEN KAYITLAR DA ALINIR.


 ---------------------------------------------------------------------------

-- INTERSECT (KUME KESISIMI)

SELECT "CompanyName", "Country" FROM "customers"
INTERSECT
SELECT "CompanyName", "Country" FROM "suppliers"
ORDER BY 2;

-- HEM TEDARIKCI HEM DE MUSTERI OLAN SIRKETLER LISTELERNIR

--------------------------------------------------------------------------- 

-- EXCEPT

SELECT "CompanyName", "Country" FROM "customers"
EXCEPT
SELECT "CompanyName", "Country" FROM "suppliers"
ORDER BY 2;

-- MUSTERI OLUP TEDARIKCI OLMAYAN SIRKETLER LISTELENIR

--------------------------------------------------------------------------- 

-- HAREKET- ISLEM (TRANSACTION)

BEGIN; -- Harekete (transaction) başla. (YANI YENI BIR HAREKET ACAR.)

INSERT INTO "order_details" ("OrderID", "ProductID", "UnitPrice", "Quantity", "Discount")
VALUES (10248, 11, 20, 2, 0);

-- Yukarıdaki sorguda hata mevcutsa ilerlenilmez.
-- Aşağıdaki sorguda hata mevcutsa bu noktadan geri sarılır (rollback).
-- Yani yukarıdaki sorguda yapılan işlemler geri alınır.

UPDATE "products" 
SET "UnitsInStock" = "UnitsInStock" - 2
WHERE "ProductID" = 11;

-- Her iki sorgu da hatasız bir şekilde icra edilirse her ikisini de işlet ve 
-- veritabanının durumunu güncelle.
--Eğer UPDATE komutu başarısız olursa (örneğin stok miktarı 0'ın altına düşemiyorsa ve bu bir kısıtlamaysa), veritabanı otomatik olarak veya açıkça ROLLBACK komutuyla, hem UPDATE işlemini hem de daha önce başarılı olan INSERT işlemini geri alır. Veritabanı, işlem başlamadan önceki durumuna döner.

COMMIT; -- Hareketi (transaction) tamamla.

----------------------------------------------

BEGIN;

UPDATE Hesap SET bakiye = bakiye - 100.00
    WHERE adi = 'Ahmet';

SAVEPOINT my_savepoint;  --> Ara kayıt noktası oluşturulur. İşlem sırasında bir hata oluşursa veya mantıksal bir geri alma gerekirse, tüm işlemi en başa (BEGIN) geri almak yerine, sadece bu noktaya (my_savepoint) kadar geri almak mümkündür.

UPDATE Hesap SET bakiye = bakiye + 100.00
    WHERE adi = 'Mehmet';


-- Parayı Mehmet'e değil Ayşe'ye gönder

ROLLBACK TO my_savepoint; --> ROLLBACK KOMUTU ILE SAVEPOINT'E GERI DONULUR. Sadece SAVEPOINT'ten sonra yapılan işlemler geri alınır.

UPDATE Hesap SET bakiye = bakiye + 100.00
WHERE adi = 'Ayşe';

COMMIT;


















 
 
 
 
 