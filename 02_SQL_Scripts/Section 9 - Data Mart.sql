CREATE OR ALTER VIEW mart.vSalesAnalytics AS
SELECT  f.SalesKey, f.OrderID,
        d.FullDate, d.YearNo, d.QuarterName, d.MonthNo, d.MonthName, d.YearMonth, d.DayName, d.IsWeekend,
        c.CustomerSegment, c.Gender, c.AgeGroup, c.City,
        l.Country, l.Region, l.StateProvince,
        p.ProductCategory, p.ProductSubcategory, p.Brand, p.ProductName,
        ch.SalesChannel, pay.PaymentMethod, pay.PaymentStatus,
        mk.MarketingChannel, mk.CampaignName, mk.CouponUsed,
        os.OrderStatus, os.ReturnStatus,
        f.Quantity, f.GrossSales, f.DiscountAmount, f.TaxAmount, f.ShippingCost,
        f.NetSales, f.ProductCost, f.Profit
FROM dw.FactSales f
JOIN dw.DimDate         d   ON d.DateKey = f.DateKey
JOIN dw.DimCustomer     c   ON c.CustomerKey = f.CustomerKey
JOIN dw.DimLocation     l   ON l.LocationKey = f.LocationKey
JOIN dw.DimProduct      p   ON p.ProductKey = f.ProductKey
JOIN dw.DimSalesChannel ch  ON ch.SalesChannelKey = f.SalesChannelKey
JOIN dw.DimPayment      pay ON pay.PaymentKey = f.PaymentKey
JOIN dw.DimMarketing    mk  ON mk.MarketingKey = f.MarketingKey
JOIN dw.DimOrderStatus  os  ON os.OrderStatusKey = f.OrderStatusKey;
GO
 
-- Pre-aggregated table for fast dashboards (roll-up level: month x region x category x segment x channel)
SELECT  YearNo, MonthNo, YearMonth, Region, ProductCategory, CustomerSegment, SalesChannel,
        COUNT(DISTINCT OrderID) AS Orders,
        SUM(Quantity)           AS UnitsSold,
        SUM(GrossSales)         AS GrossSales,
        SUM(DiscountAmount)     AS DiscountAmount,
        SUM(NetSales)           AS NetSales,
        SUM(Profit)             AS Profit
INTO mart.SalesMonthlySummary
FROM mart.vSalesAnalytics
GROUP BY YearNo, MonthNo, YearMonth, Region, ProductCategory, CustomerSegment, SalesChannel;
GO