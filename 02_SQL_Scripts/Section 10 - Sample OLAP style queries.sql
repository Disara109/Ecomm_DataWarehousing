-- Roll-up: Year > Quarter > Month net sales and profit with subtotals
SELECT YearNo, QuarterName, MonthName, SUM(NetSales) AS NetSales, SUM(Profit) AS Profit
FROM mart.vSalesAnalytics
GROUP BY ROLLUP (YearNo, QuarterName, MonthName)
ORDER BY YearNo, QuarterName, MonthName;
 
-- Cube-style: Category x Region
SELECT ProductCategory, Region, SUM(NetSales) AS NetSales
FROM mart.vSalesAnalytics
GROUP BY CUBE (ProductCategory, Region);
 
-- Slice: 2024 only, by sales channel
SELECT SalesChannel, SUM(NetSales) AS NetSales, SUM(Profit) AS Profit
FROM mart.vSalesAnalytics
WHERE YearNo = 2024
GROUP BY SalesChannel;
 
-- Return rate by month (order grain - uses the order-level fact)
SELECT d.YearMonth, COUNT(*) AS Orders, SUM(CAST(f.ReturnedFlag AS int)) AS ReturnedOrders,
       100.0 * SUM(CAST(f.ReturnedFlag AS int)) / COUNT(*) AS ReturnRatePct
FROM dw.FactOrderService f JOIN dw.DimDate d ON d.DateKey = f.DateKey
GROUP BY d.YearMonth ORDER BY d.YearMonth;
GO