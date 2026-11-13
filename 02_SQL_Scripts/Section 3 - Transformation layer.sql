CREATE OR ALTER VIEW stg.vCustomers AS
SELECT  LTRIM(RTRIM(customer_id))                                         AS CustomerID,
        COALESCE(NULLIF(LTRIM(RTRIM(customer_name)),''),'Unknown')        AS CustomerName,
        TRY_CONVERT(int, TRY_CONVERT(decimal(6,1), customer_age))         AS Age,
        COALESCE(NULLIF(LTRIM(RTRIM(gender)),''),'Unknown')               AS Gender,
        COALESCE(NULLIF(LTRIM(RTRIM(customer_segment)),''),'Unknown')     AS CustomerSegment,
        COALESCE(NULLIF(LTRIM(RTRIM(customer_city)),''),'Unknown')        AS City,
        COALESCE(NULLIF(LTRIM(RTRIM(customer_state)),''),'Unknown')       AS StateProvince,
        COALESCE(NULLIF(LTRIM(RTRIM(customer_country)),''),'Unknown')     AS Country,
        COALESCE(NULLIF(LTRIM(RTRIM(region)),''),'Unknown')               AS Region,
        COALESCE(NULLIF(LTRIM(RTRIM(CAST(customer_postal_code AS nvarchar(50)))),''),'Unknown') AS PostalCode,
        TRY_CONVERT(decimal(18,2), customer_acquisition_cost)             AS AcquisitionCost
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY (SELECT NULL)) AS rn
      FROM stg.customer_master) x
WHERE rn = 1;                                   -- duplicate removal
GO
 
CREATE OR ALTER VIEW stg.vProducts AS
SELECT  LTRIM(RTRIM(product_id))                                          AS ProductID,
        COALESCE(NULLIF(LTRIM(RTRIM(product_name)),''),'Unknown')         AS ProductName,
        COALESCE(NULLIF(LTRIM(RTRIM(product_category)),''),'Unknown')     AS ProductCategory,
        COALESCE(NULLIF(LTRIM(RTRIM(product_subcategory)),''),'Unknown')  AS ProductSubcategory,
        COALESCE(NULLIF(LTRIM(RTRIM(brand)),''),'Unknown')                AS Brand,
        COALESCE(NULLIF(LTRIM(RTRIM(supplier)),''),'Unknown')             AS Supplier,
        TRY_CONVERT(decimal(18,2), unit_price)                            AS ListPrice,
        TRY_CONVERT(decimal(18,2), product_cost)                          AS StandardCost,
        TRY_CONVERT(decimal(4,2),  product_rating)                        AS ProductRating
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY (SELECT NULL)) AS rn
      FROM stg.product_catalog) x
WHERE rn = 1;
GO
 
/* NOTE: if order_date is not ISO (yyyy-mm-dd) e.g. dd/mm/yyyy, change to
   TRY_CONVERT(date, order_date, 103)                                      */
CREATE OR ALTER VIEW stg.vOrders AS
SELECT  LTRIM(RTRIM(order_id))                                            AS OrderID,
        TRY_CONVERT(date, order_date)                                     AS OrderDate,
        LTRIM(RTRIM(customer_id))                                         AS CustomerID,
        COALESCE(NULLIF(LTRIM(RTRIM(order_status)),''),'Not Applicable')  AS OrderStatus,
        COALESCE(NULLIF(LTRIM(RTRIM(sales_channel)),''),'Not Applicable') AS SalesChannel,
        COALESCE(NULLIF(LTRIM(RTRIM(payment_method)),''),'Not Applicable')AS PaymentMethod,
        COALESCE(NULLIF(LTRIM(RTRIM(payment_status)),''),'Not Applicable')AS PaymentStatus,
        COALESCE(NULLIF(LTRIM(RTRIM(shipping_method)),''),'Not Applicable')AS ShippingMethod,
        COALESCE(NULLIF(LTRIM(RTRIM(warehouse)),''),'Not Applicable')     AS Warehouse,
        COALESCE(NULLIF(LTRIM(RTRIM(delivery_status)),''),'Not Applicable')AS DeliveryStatus,
        TRY_CONVERT(int, TRY_CONVERT(decimal(10,2), delivery_days))           AS DeliveryDays,           -- NULL kept = unavailable
        TRY_CONVERT(int, TRY_CONVERT(decimal(10,2), estimated_delivery_days)) AS EstimatedDeliveryDays,  -- NULL kept = unavailable
        COALESCE(NULLIF(LTRIM(RTRIM(marketing_channel)),''),'Not Applicable') AS MarketingChannel,
        COALESCE(NULLIF(LTRIM(RTRIM(campaign_name)),''),'No Campaign')    AS CampaignName,
        CASE WHEN NULLIF(LTRIM(RTRIM(coupon_code)),'') IS NULL THEN 'No Coupon' ELSE 'Coupon Used' END AS CouponUsed,
        TRY_CONVERT(int, TRY_CONVERT(decimal(12,2), loyalty_points_earned))   AS LoyaltyPointsEarned,
        TRY_CONVERT(int, TRY_CONVERT(decimal(12,2), loyalty_points_redeemed)) AS LoyaltyPointsRedeemed,
        TRY_CONVERT(decimal(3,1), customer_rating)                        AS CustomerRating,         -- NULL kept = not rated
        COALESCE(NULLIF(LTRIM(RTRIM(return_status)),''),'Not Returned')   AS ReturnStatus,
        COALESCE(NULLIF(LTRIM(RTRIM(return_reason)),''),'Not Applicable') AS ReturnReason
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY (SELECT NULL)) AS rn
      FROM stg.sales) x
WHERE rn = 1;
GO
 
CREATE OR ALTER VIEW stg.vOrderItems AS
SELECT  LTRIM(RTRIM(order_id))                                  AS OrderID,
        LTRIM(RTRIM(product_id))                                AS ProductID,
        TRY_CONVERT(int, TRY_CONVERT(decimal(12,2), quantity))  AS Quantity,
        TRY_CONVERT(decimal(18,2), unit_price)                  AS UnitPrice,
        TRY_CONVERT(decimal(9,4),  discount_percentage)         AS DiscountPercentage,
        TRY_CONVERT(decimal(18,2), discount_amount)             AS DiscountAmount,
        TRY_CONVERT(decimal(18,2), gross_sales)                 AS GrossSales,
        TRY_CONVERT(decimal(18,2), tax_amount)                  AS TaxAmount,
        TRY_CONVERT(decimal(18,2), shipping_cost)               AS ShippingCost,
        TRY_CONVERT(decimal(18,2), net_sales)                   AS NetSales,
        TRY_CONVERT(decimal(18,2), product_cost)                AS ProductCost,
        TRY_CONVERT(decimal(18,2), profit)                      AS Profit
FROM stg.order_items;
GO

SELECT name FROM sys.views WHERE schema_id = SCHEMA_ID('stg');