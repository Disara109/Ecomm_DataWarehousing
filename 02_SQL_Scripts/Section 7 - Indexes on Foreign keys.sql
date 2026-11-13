CREATE INDEX IX_FactSales_Date     ON dw.FactSales(DateKey);
CREATE INDEX IX_FactSales_Customer ON dw.FactSales(CustomerKey);
CREATE INDEX IX_FactSales_Product  ON dw.FactSales(ProductKey);
CREATE INDEX IX_FactSales_Location ON dw.FactSales(LocationKey);
CREATE INDEX IX_FactSales_Order    ON dw.FactSales(OrderID);
CREATE INDEX IX_FactOrder_Date     ON dw.FactOrderService(DateKey);
CREATE INDEX IX_FactOrder_Customer ON dw.FactOrderService(CustomerKey);
GO