CREATE OR ALTER VIEW stg.vCustomerLocation AS
SELECT c.CustomerID, l.LocationKey
FROM stg.vCustomers c
JOIN dw.DimLocation l
  ON  l.Country = c.Country AND l.Region = c.Region AND l.StateProvince = c.StateProvince;
GO
 
CREATE OR ALTER VIEW stg.vOrderKeys AS
SELECT  o.OrderID,
        ISNULL(d.DateKey, -1)  AS DateKey,
        c.CustomerKey, cl.LocationKey, ch.SalesChannelKey, pay.PaymentKey,
        mk.MarketingKey, sh.ShippingKey, os.OrderStatusKey
FROM stg.vOrders o
JOIN dw.DimCustomer         c   ON c.CustomerID = o.CustomerID
JOIN stg.vCustomerLocation  cl  ON cl.CustomerID = o.CustomerID
LEFT JOIN dw.DimDate        d   ON d.FullDate = o.OrderDate
JOIN dw.DimSalesChannel     ch  ON ch.SalesChannel = o.SalesChannel
JOIN dw.DimPayment          pay ON pay.PaymentMethod = o.PaymentMethod AND pay.PaymentStatus = o.PaymentStatus
JOIN dw.DimMarketing        mk  ON mk.MarketingChannel = o.MarketingChannel AND mk.CampaignName = o.CampaignName AND mk.CouponUsed = o.CouponUsed
JOIN dw.DimShipping         sh  ON sh.ShippingMethod = o.ShippingMethod AND sh.Warehouse = o.Warehouse
JOIN dw.DimOrderStatus      os  ON os.OrderStatus = o.OrderStatus AND os.DeliveryStatus = o.DeliveryStatus
                               AND os.ReturnStatus = o.ReturnStatus AND os.ReturnReason = o.ReturnReason;
GO
 
INSERT INTO dw.FactSales
      (OrderID, DateKey, CustomerKey, ProductKey, LocationKey, SalesChannelKey, PaymentKey,
       MarketingKey, ShippingKey, OrderStatusKey, Quantity, UnitPrice, DiscountPercentage,
       DiscountAmount, GrossSales, TaxAmount, ShippingCost, NetSales, ProductCost, Profit)
SELECT  oi.OrderID, k.DateKey, k.CustomerKey, p.ProductKey, k.LocationKey, k.SalesChannelKey, k.PaymentKey,
        k.MarketingKey, k.ShippingKey, k.OrderStatusKey, oi.Quantity, oi.UnitPrice, oi.DiscountPercentage,
        oi.DiscountAmount, oi.GrossSales, oi.TaxAmount, oi.ShippingCost, oi.NetSales, oi.ProductCost, oi.Profit
FROM stg.vOrderItems oi
JOIN stg.vOrderKeys k ON k.OrderID = oi.OrderID
JOIN dw.DimProduct  p ON p.ProductID = oi.ProductID;
 
INSERT INTO dw.FactOrderService
      (OrderID, DateKey, CustomerKey, LocationKey, SalesChannelKey, PaymentKey, MarketingKey,
       ShippingKey, OrderStatusKey, DeliveryDays, EstimatedDeliveryDays, DeliveryDelayDays,
       CustomerRating, LoyaltyPointsEarned, LoyaltyPointsRedeemed, ReturnedFlag, CancelledFlag)
SELECT  o.OrderID, k.DateKey, k.CustomerKey, k.LocationKey, k.SalesChannelKey, k.PaymentKey, k.MarketingKey,
        k.ShippingKey, k.OrderStatusKey, o.DeliveryDays, o.EstimatedDeliveryDays,
        o.DeliveryDays - o.EstimatedDeliveryDays,
        o.CustomerRating, o.LoyaltyPointsEarned, o.LoyaltyPointsRedeemed,
        CASE WHEN o.ReturnStatus <> 'Not Returned' THEN 1 ELSE 0 END,   -- check SELECT DISTINCT return_status first
        CASE WHEN o.OrderStatus LIKE 'Cancel%' THEN 1 ELSE 0 END        -- check SELECT DISTINCT order_status first
FROM stg.vOrders o
JOIN stg.vOrderKeys k ON k.OrderID = o.OrderID;
GO