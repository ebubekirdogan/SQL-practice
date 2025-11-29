SELECT * FROM "customers" WHERE "Country" ='Germany' ORDER BY "CompanyName" ASC;
-- Almanya Ülkesini Sorugulama

SELECT DISTINCT "Country" AS "MusteriUlke" FROM "customers"; 
--kaç farklı ülke olduğunu sorgulama

SELECT * FROM "products"
 WHERE "UnitPrice" BETWEEN 10 AND 20
ORDER BY "UnitPrice" DESC;
-- products tablosundan, birim fiyatı (UnitPrice) 10 ile 20 (bu limitler dahil) arasında olan tüm ürünlerin listelenmesi.

SELECT "CompanyName" , "Country" FROM "customers" WHERE "Region" IS NULL;
-- customers tablosunu kullanarak, Region (Bölge) sütununda hiçbir veri olmayan (NULL) müşterileri listeleyin.Listede sadece CompanyName ve Country sütunları görünsün.

INSERT INTO "employees" ("EmployeeID" , "FirstName" , "LastName")
VALUES (105,'Ebubekir','DOĞAN');

UPDATE "employees" SET "Title" = 'Veri Analisti'
WHERE "EmployeeID" = '105' ;

-- kontrol işlemi:
--SELECT * FROM "employees" WHERE "Title" = 'Veri Analisti';

DELETE FROM "employees"
WHERE "EmployeeID" = 105;
--silme işlemi

SELECT 
"public"."orders"."OrderID",
"public"."customers"."CompanyName",
"public"."orders"."OrderDate"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID";
-- INNER JOIN ILE TABLO BIRLESTIRME

SELECT 
"public"."orders"."OrderID",
"public"."customers"."CompanyName",
"public"."employees"."FirstName",
"public"."employees"."LastName"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID"
INNER JOIN "employees" ON "orders"."EmployeeID" = "employees"."EmployeeID";
-- ÜÇ TABLO BİRLEŞTİRME

/*  SELECT 
    "orders"."OrderID", 
    "customers"."CompanyName", 
    "employees"."FirstName", 
    "employees"."LastName"
FROM "customers"  -- Başlangıç customers oldu
INNER JOIN "orders" ON "customers"."CustomerID" = "orders"."CustomerID"
INNER JOIN "employees" ON "orders"."EmployeeID" = "employees"."EmployeeID";

-- ÜÇ TABLO BİRLEŞTİRME -> BU İŞLEMDE MÜMKÜNDÜR.
*/

SELECT 
"customers"."CompanyName",
"orders"."OrderID"
FROM "customers"
LEFT OUTER JOIN "orders" ON "customers"."CustomerID" = "orders"."CustomerID"
WHERE "orders"."OrderID" IS NULL;
-- sol dış birleştirme 

SELECT 
"employees"."FirstName",
"employees"."LastName",
"orders"."OrderID"
FROM "orders"
RIGHT OUTER JOIN "employees" ON "orders"."EmployeeID" = "employees"."EmployeeID";
 
 -- sağ dış birleştirme
















