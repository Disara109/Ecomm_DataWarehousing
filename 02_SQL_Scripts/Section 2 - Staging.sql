;WITH expected(tbl, col) AS (
  SELECT * FROM (VALUES
   ('sales','order_id'),('sales','order_date'),('sales','customer_id'),('sales','order_status'),
   ('sales','sales_channel'),('sales','payment_method'),('sales','payment_status'),
   ('sales','shipping_method'),('sales','warehouse'),('sales','delivery_days'),
   ('sales','estimated_delivery_days'),('sales','delivery_status'),('sales','marketing_channel'),
   ('sales','campaign_name'),('sales','coupon_code'),('sales','loyalty_points_earned'),
   ('sales','loyalty_points_redeemed'),('sales','customer_rating'),('sales','return_status'),
   ('sales','return_reason'),
   ('customer_master','customer_id'),('customer_master','customer_name'),('customer_master','customer_age'),
   ('customer_master','gender'),('customer_master','customer_segment'),('customer_master','customer_city'),
   ('customer_master','customer_state'),('customer_master','customer_country'),('customer_master','region'),
   ('customer_master','customer_postal_code'),('customer_master','customer_acquisition_cost'),
   ('product_catalog','product_id'),('product_catalog','product_name'),('product_catalog','product_category'),
   ('product_catalog','product_subcategory'),('product_catalog','brand'),('product_catalog','supplier'),
   ('product_catalog','unit_price'),('product_catalog','product_cost'),('product_catalog','product_rating'),
   ('order_items','order_id'),('order_items','product_id'),('order_items','quantity'),
   ('order_items','unit_price'),('order_items','discount_percentage'),('order_items','discount_amount'),
   ('order_items','gross_sales'),('order_items','tax_amount'),('order_items','shipping_cost'),
   ('order_items','net_sales'),('order_items','product_cost'),('order_items','profit')
  ) v(tbl, col)
)
SELECT e.tbl AS StagingTable, e.col AS MissingColumn
FROM expected e
LEFT JOIN INFORMATION_SCHEMA.COLUMNS ic
       ON ic.TABLE_SCHEMA = 'stg' AND ic.TABLE_NAME = e.tbl AND ic.COLUMN_NAME = e.col
WHERE ic.COLUMN_NAME IS NULL;
GO

SELECT TOP 5 order_date FROM stg.sales;