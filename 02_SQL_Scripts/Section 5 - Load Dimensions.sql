-- Date dimension (generated; covers the 2021-2025 order range) + unknown member
INSERT INTO dw.DimDate VALUES (-1,'1900-01-01',1,'Unknown',1,1,'Unknown',1,'Q1',1900,'1900-01',0);
 
;WITH d AS (
    SELECT CAST('2021-01-01' AS date) AS dt
    UNION ALL
    SELECT DATEADD(DAY,1,dt) FROM d WHERE dt < '2025-12-31'
)
INSERT INTO dw.DimDate
SELECT  CONVERT(int, CONVERT(char(8), dt, 112)), dt, DAY(dt), DATENAME(WEEKDAY, dt),
        DATEPART(ISO_WEEK, dt), MONTH(dt), DATENAME(MONTH, dt), DATEPART(QUARTER, dt),
        'Q' + CAST(DATEPART(QUARTER, dt) AS char(1)), YEAR(dt), CONVERT(char(7), dt, 120),
        CASE WHEN DATENAME(WEEKDAY, dt) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
FROM d
OPTION (MAXRECURSION 0);
 
INSERT INTO dw.DimLocation (Country, Region, StateProvince)
SELECT DISTINCT Country, Region, StateProvince FROM stg.vCustomers;
 
INSERT INTO dw.DimCustomer (CustomerID, CustomerName, Age, AgeGroup, Gender, CustomerSegment, City, PostalCode, AcquisitionCost)
SELECT  CustomerID, CustomerName, Age,
        CASE WHEN Age IS NULL THEN 'Unknown'
             WHEN Age < 25 THEN 'Under 25'
             WHEN Age < 35 THEN '25-34'
             WHEN Age < 45 THEN '35-44'
             WHEN Age < 55 THEN '45-54'
             ELSE '55+' END,
        Gender, CustomerSegment, City, PostalCode, AcquisitionCost
FROM stg.vCustomers;
 
INSERT INTO dw.DimProduct (ProductID, ProductName, ProductCategory, ProductSubcategory, Brand, Supplier, ListPrice, StandardCost, ProductRating)
SELECT ProductID, ProductName, ProductCategory, ProductSubcategory, Brand, Supplier, ListPrice, StandardCost, ProductRating
FROM stg.vProducts;
 
INSERT INTO dw.DimSalesChannel (SalesChannel)
SELECT DISTINCT SalesChannel FROM stg.vOrders;
 
INSERT INTO dw.DimPayment (PaymentMethod, PaymentStatus)
SELECT DISTINCT PaymentMethod, PaymentStatus FROM stg.vOrders;
 
INSERT INTO dw.DimMarketing (MarketingChannel, CampaignName, CouponUsed)
SELECT DISTINCT MarketingChannel, CampaignName, CouponUsed FROM stg.vOrders;
 
INSERT INTO dw.DimShipping (ShippingMethod, Warehouse)
SELECT DISTINCT ShippingMethod, Warehouse FROM stg.vOrders;
 
INSERT INTO dw.DimOrderStatus (OrderStatus, DeliveryStatus, ReturnStatus, ReturnReason)
SELECT DISTINCT OrderStatus, DeliveryStatus, ReturnStatus, ReturnReason FROM stg.vOrders;
GO


SELECT 'DimCustomer' AS tbl, COUNT(*) AS n FROM dw.DimCustomer
UNION ALL SELECT 'DimProduct', COUNT(*) FROM dw.DimProduct
UNION ALL SELECT 'DimLocation', COUNT(*) FROM dw.DimLocation
UNION ALL SELECT 'DimDate', COUNT(*) FROM dw.DimDate;