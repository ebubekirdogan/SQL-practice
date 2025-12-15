SET search_path TO public;

CREATE OR REPLACE VIEW "public"."SiparisMusteriSatisTemsilcisi" AS
SELECT
    "orders"."OrderID",
    "orders"."OrderDate",
    "customers"."CompanyName",
    "customers"."ContactName",
    "employees"."FirstName",
    "employees"."LastName"
FROM "orders"
INNER JOIN "employees" ON "orders"."EmployeeID" = "employees"."EmployeeID"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID";

SELECT * FROM "SiparisMusteriSatisTemsilcisi";
-- şimdi her defasında sorgulama kodunu yazmamıza gerek yok. canlıdır. veri ekleme-silme işlemi olsa dahi bu kısayol sorgusu ile ksıaca ulaşabileceğiz.

DROP VIEW "SiparisMusteriSatisTemsilcisi"; 
-- sadece kısayolu siler.

--------------------------------------------------------------------

-- ÇOKLU SATIR FONKSİYONLARI 

-- Count: kaç tane var sorusunun cevabını verir.
SELECT COUNT(*) AS "Meksikadaki müşteri sayısı"
FROM "customers"
WHERE "Country" = 'Mexico';

SELECT COUNT(*) FROM "customers";

-- ! Count her şeyi sayar ancak eğer sütun adı verilirse NULL alanları saymaz

SELECT COUNT("Region")
FROM "customers"
WHERE "Country" = 'Mexico';

-- LIMIT

SELECT * FROM "products"
ORDER BY "ProductID" ASC
LIMIT 4;

-- ID' ye gore sıralama yapıdıgında ilk 4 sonuc getirilir.

SELECT * FROM "products"
ORDER BY "ProductID" DESC
LIMIT 4;

-- ID' ye gore sıralama yapıdıgında son 4 sonuc getirilir.(sorguda cikan en ustteki sonuc en sonuncu olacak şekilde)

-- MAX

SELECT MAX("UnitPrice") AS "enYuksekFiyat" FROM "products"; 
-- products tablosundaki UnitPrice değeri en yüksek olan değer getirilir

-- MIN

SELECT MIN("UnitPrice") AS "enDusukFiyat" FROM "products";

- SUM

SELECT SUM("UnitPrice") AS "toplamFiyat" FROM "products";

-- tüm ürünlerin birim fiyatlarını toplar.

-- AVG
SELECT SUM("UnitPrice") / COUNT("ProductID") AS "ortalamaElle" FROM "products";
-- ürün başı ortalama fiaytı hesapalar

SELECT AVG("UnitPrice") AS "ortalamaOtomatik" FROM "products"; 
-- bu işlem AVG ile kısaca yapılabilir.

----------------------------------------------------------------

-- GROUP BY

SELECT "SupplierID", COUNT("ProductID") AS "urunSayisi"
FROM "products"
GROUP BY "SupplierID";

-- hangi toptancıdan kaçar tane ürün var SupplierID' ye göre' gruplar

SELECT "SupplierID", SUM("UnitsInStock") AS "stokSayisi"
FROM "products"
GROUP BY "SupplierID";
 
-- hangi tedarikçinin ne kadar stoğu var SupplierID' ye göre gruplar

SELECT
    "customers"."CompanyName",
    COUNT("orders"."OrderID") AS "SiparisSayisi",
    SUM("order_details"."UnitPrice" * "order_details"."Quantity") AS "ToplamHarcama"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID"
INNER JOIN "order_details" ON "order_details"."OrderID" = "orders"."OrderID"
GROUP BY "customers"."CompanyName"
ORDER BY "ToplamHarcama" DESC;

-- bu örnek , "Hangi müşterimiz, toplam kaç sipariş vermiş ve bu siparişlerin toplam tutarı ne kadar?" sorusunu cevaplar.

------------------------------------------------------

-- HAVING 

-- Gruplama işleminden sonra koşul yazılabilmesi için WHERE yerine HAVING kullanılmalıdır !

SELECT "SupplierID", COUNT("SupplierID") AS "urunCesitiSayisi"
FROM "products"
GROUP BY "SupplierID"
HAVING COUNT("SupplierID") > 2;

-- bu sorgu bize sadece 2den fazla ürün satan tedarikçielr getirilir (count group by ile kullanıldığında; gruplama işleminden sonra sayma işlemi yapar.)

----------------------------------

-- ÇOKLU SATIR FONKSIYONLAR ILE(COUNT,SUM,MAX,MIN,AVG) WHERE KULLANILAMAZ! ASAGIDAKI IKI ORNEK HATALIDIR !

SELECT "SupplierID", COUNT("SupplierID") AS "urunSayisi"
FROM "products"
GROUP BY "SupplierID"
HAVING COUNT("SupplierID") > 2;

SELECT "SupplierID", COUNT("SupplierID") AS "urunSayisi"
FROM "products"
HAVING COUNT("SupplierID") > 2;

-- COKLU SATIR FONK.LARI YOKKEN GROUP BY ILE WHERE KULLANILABILIR.































