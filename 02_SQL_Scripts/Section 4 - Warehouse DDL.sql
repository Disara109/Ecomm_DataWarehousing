DROP VIEW  IF EXISTS mart.vSalesAnalytics;
DROP TABLE IF EXISTS mart.SalesMonthlySummary;
DROP VIEW  IF EXISTS stg.vOrderKeys;
DROP VIEW  IF EXISTS stg.vCustomerLocation;
DROP TABLE IF EXISTS dw.FactOrderService;
DROP TABLE IF EXISTS dw.FactSales;
DROP TABLE IF EXISTS dw.DimOrderStatus;
DROP TABLE IF EXISTS dw.DimShipping;
DROP TABLE IF EXISTS dw.DimMarketing;
DROP TABLE IF EXISTS dw.DimPayment;
DROP TABLE IF EXISTS dw.DimSalesChannel;
DROP TABLE IF EXISTS dw.DimProduct;
DROP TABLE IF EXISTS dw.DimCustomer;
DROP TABLE IF EXISTS dw.DimLocation;
DROP TABLE IF EXISTS dw.DimDate;
GO
 
/* Hierarchy: Year > Quarter > Month > Date */
CREATE TABLE dw.DimDate (
    DateKey      INT          NOT NULL PRIMARY KEY,   -- yyyymmdd; -1 = unknown date
    FullDate     DATE         NOT NULL,
    DayOfMonth   TINYINT      NOT NULL,
    DayName      VARCHAR(10)  NOT NULL,
    WeekOfYear   TINYINT      NOT NULL,
    MonthNo      TINYINT      NOT NULL,
    MonthName    VARCHAR(10)  NOT NULL,
    QuarterNo    TINYINT      NOT NULL,
    QuarterName  CHAR(2)      NOT NULL,
    YearNo       SMALLINT     NOT NULL,
    YearMonth    CHAR(7)      NOT NULL,
    IsWeekend    BIT          NOT NULL
);
 
/* Hierarchy: Country > Region > State/Province
   (city values are near-unique per customer, so City/PostalCode live in DimCustomer) */
CREATE TABLE dw.DimLocation (
    LocationKey   INT IDENTITY(1,1) PRIMARY KEY,
    Country       NVARCHAR(100) NOT NULL,
    Region        NVARCHAR(100) NOT NULL,
    StateProvince NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimLocation UNIQUE (Country, Region, StateProvince)
);
 
CREATE TABLE dw.DimCustomer (
    CustomerKey     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID      VARCHAR(50)   NOT NULL UNIQUE,    -- business key
    CustomerName    NVARCHAR(200) NOT NULL,
    Age             INT           NULL,
    AgeGroup        VARCHAR(10)   NOT NULL,           -- derived
    Gender          VARCHAR(30)   NOT NULL,
    CustomerSegment VARCHAR(50)   NOT NULL,
    City            NVARCHAR(100) NOT NULL,
    PostalCode      NVARCHAR(50)  NOT NULL,
    AcquisitionCost DECIMAL(18,2) NULL
);
 
/* Hierarchy: Category > Subcategory > Product */
CREATE TABLE dw.DimProduct (
    ProductKey         INT IDENTITY(1,1) PRIMARY KEY,
    ProductID          VARCHAR(50)   NOT NULL UNIQUE,
    ProductName        NVARCHAR(200) NOT NULL,
    ProductCategory    NVARCHAR(100) NOT NULL,
    ProductSubcategory NVARCHAR(100) NOT NULL,
    Brand              NVARCHAR(100) NOT NULL,
    Supplier           NVARCHAR(150) NOT NULL,
    ListPrice          DECIMAL(18,2) NULL,
    StandardCost       DECIMAL(18,2) NULL,
    ProductRating      DECIMAL(4,2)  NULL
);
 
CREATE TABLE dw.DimSalesChannel (
    SalesChannelKey INT IDENTITY(1,1) PRIMARY KEY,
    SalesChannel    NVARCHAR(100) NOT NULL UNIQUE
);
 
CREATE TABLE dw.DimPayment (
    PaymentKey    INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod NVARCHAR(100) NOT NULL,
    PaymentStatus NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimPayment UNIQUE (PaymentMethod, PaymentStatus)
);
 
CREATE TABLE dw.DimMarketing (
    MarketingKey     INT IDENTITY(1,1) PRIMARY KEY,
    MarketingChannel NVARCHAR(100) NOT NULL,
    CampaignName     NVARCHAR(200) NOT NULL,
    CouponUsed       VARCHAR(20)   NOT NULL,
    CONSTRAINT UQ_DimMarketing UNIQUE (MarketingChannel, CampaignName, CouponUsed)
);
 
CREATE TABLE dw.DimShipping (
    ShippingKey    INT IDENTITY(1,1) PRIMARY KEY,
    ShippingMethod NVARCHAR(100) NOT NULL,
    Warehouse      NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimShipping UNIQUE (ShippingMethod, Warehouse)
);
 
/* Junk dimension: low-cardinality order / delivery / return flags */
CREATE TABLE dw.DimOrderStatus (
    OrderStatusKey INT IDENTITY(1,1) PRIMARY KEY,
    OrderStatus    NVARCHAR(100) NOT NULL,
    DeliveryStatus NVARCHAR(100) NOT NULL,
    ReturnStatus   NVARCHAR(100) NOT NULL,
    ReturnReason   NVARCHAR(200) NOT NULL,
    CONSTRAINT UQ_DimOrderStatus UNIQUE (OrderStatus, DeliveryStatus, ReturnStatus, ReturnReason)
);
 
/* FACT 1 - Business process: Sales
   GRAIN: one row per product line item within an order (order_items)   */
CREATE TABLE dw.FactSales (
    SalesKey           BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID            VARCHAR(50) NOT NULL,                       -- degenerate dimension
    DateKey            INT NOT NULL REFERENCES dw.DimDate(DateKey),
    CustomerKey        INT NOT NULL REFERENCES dw.DimCustomer(CustomerKey),
    ProductKey         INT NOT NULL REFERENCES dw.DimProduct(ProductKey),
    LocationKey        INT NOT NULL REFERENCES dw.DimLocation(LocationKey),
    SalesChannelKey    INT NOT NULL REFERENCES dw.DimSalesChannel(SalesChannelKey),
    PaymentKey         INT NOT NULL REFERENCES dw.DimPayment(PaymentKey),
    MarketingKey       INT NOT NULL REFERENCES dw.DimMarketing(MarketingKey),
    ShippingKey        INT NOT NULL REFERENCES dw.DimShipping(ShippingKey),
    OrderStatusKey     INT NOT NULL REFERENCES dw.DimOrderStatus(OrderStatusKey),
    Quantity           INT           NULL,
    UnitPrice          DECIMAL(18,2) NULL,
    DiscountPercentage DECIMAL(9,4)  NULL,
    DiscountAmount     DECIMAL(18,2) NULL,
    GrossSales         DECIMAL(18,2) NULL,
    TaxAmount          DECIMAL(18,2) NULL,
    ShippingCost       DECIMAL(18,2) NULL,
    NetSales           DECIMAL(18,2) NULL,
    ProductCost        DECIMAL(18,2) NULL,
    Profit             DECIMAL(18,2) NULL
);
 
/* FACT 2 - Business process: Order fulfilment & customer service
   GRAIN: one row per order (delivery, rating, returns live at order level,
   so they must NOT sit on the line-item fact or they would be double-counted) */
CREATE TABLE dw.FactOrderService (
    OrderServiceKey       BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID               VARCHAR(50) NOT NULL UNIQUE,
    DateKey               INT NOT NULL REFERENCES dw.DimDate(DateKey),
    CustomerKey           INT NOT NULL REFERENCES dw.DimCustomer(CustomerKey),
    LocationKey           INT NOT NULL REFERENCES dw.DimLocation(LocationKey),
    SalesChannelKey       INT NOT NULL REFERENCES dw.DimSalesChannel(SalesChannelKey),
    PaymentKey            INT NOT NULL REFERENCES dw.DimPayment(PaymentKey),
    MarketingKey          INT NOT NULL REFERENCES dw.DimMarketing(MarketingKey),
    ShippingKey           INT NOT NULL REFERENCES dw.DimShipping(ShippingKey),
    OrderStatusKey        INT NOT NULL REFERENCES dw.DimOrderStatus(OrderStatusKey),
    OrderCount            TINYINT NOT NULL DEFAULT 1,
    DeliveryDays          INT NULL,
    EstimatedDeliveryDays INT NULL,
    DeliveryDelayDays     INT NULL,          -- derived: actual - estimated
    CustomerRating        DECIMAL(3,1) NULL,
    LoyaltyPointsEarned   INT NULL,
    LoyaltyPointsRedeemed INT NULL,
    ReturnedFlag          BIT NOT NULL,      -- derived
    CancelledFlag         BIT NOT NULL       -- derived
);
GO