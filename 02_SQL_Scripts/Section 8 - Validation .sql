SELECT 'Customers (rows)'     AS CheckName,
       CAST((SELECT COUNT(*) FROM stg.customer_master) AS decimal(18,2)) AS SourceValue,
       CAST((SELECT COUNT(*) FROM dw.DimCustomer)      AS decimal(18,2)) AS WarehouseValue
UNION ALL SELECT 'Products (rows)',
       (SELECT COUNT(*) FROM stg.product_catalog), (SELECT COUNT(*) FROM dw.DimProduct)
UNION ALL SELECT 'Orders (rows)',
       (SELECT COUNT(*) FROM stg.sales), (SELECT COUNT(*) FROM dw.FactOrderService)
UNION ALL SELECT 'Order items (rows)',
       (SELECT COUNT(*) FROM stg.order_items), (SELECT COUNT(*) FROM dw.FactSales)
UNION ALL SELECT 'Net sales (sum)',
       (SELECT SUM(NetSales) FROM stg.vOrderItems), (SELECT SUM(NetSales) FROM dw.FactSales)
UNION ALL SELECT 'Profit (sum)',
       (SELECT SUM(Profit) FROM stg.vOrderItems), (SELECT SUM(Profit) FROM dw.FactSales)
UNION ALL SELECT 'Quantity (sum)',
       (SELECT SUM(Quantity) FROM stg.vOrderItems), (SELECT SUM(Quantity) FROM dw.FactSales)
UNION ALL SELECT 'Orders with unknown date',
       0, (SELECT COUNT(*) FROM dw.FactOrderService WHERE DateKey = -1);
 
-- Cross-check against the provided summary file (compare by eye)
SELECT * FROM stg.dataset_statistics;
SELECT COUNT(DISTINCT OrderID) AS Orders, SUM(NetSales) AS TotalNetSales, SUM(Profit) AS TotalProfit FROM dw.FactSales;
GO
