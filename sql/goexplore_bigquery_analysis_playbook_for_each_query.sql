-- ============================================================
--  GoExplore – BigQuery Analysis Playbook
--  Project  : goexplore-505409
--  Dataset  : goexplore
--  Tables   : daily_sales | Products | Retailers | methods
--  Note     : Date column is already DATE type in BigQuery
-- ============================================================


-- ============================================================
-- 1. REVENUE & PROFIT TRENDS (Year + Month)
-- ============================================================
-- Business Question: Is the business growing YoY?
-- What is the profit margin trend over time?

SELECT
  EXTRACT(YEAR  FROM s.Date)                             AS year,
  EXTRACT(MONTH FROM s.Date)                             AS month,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)          AS total_revenue,
  ROUND(SUM(s.Quantity * p.`Unit cost`), 2)              AS total_cost,
  ROUND(SUM(s.Quantity * s.Unit_sale_price)
      - SUM(s.Quantity * p.`Unit cost`), 2)              AS gross_profit,
  ROUND(
    (SUM(s.Quantity * s.Unit_sale_price)
   - SUM(s.Quantity * p.`Unit cost`))
  / NULLIF(SUM(s.Quantity * s.Unit_sale_price), 0) * 100
  , 2)                                                   AS profit_margin_pct
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
GROUP BY 1, 2
ORDER BY 1, 2;


-- ============================================================
-- 2. PRODUCT LINE PERFORMANCE
-- ============================================================
-- Business Question: Which product lines drive the most
-- revenue and profit? Which have the best margins?

SELECT
  p.`Product line`,
  COUNT(DISTINCT s.Product_number)                        AS num_products,
  SUM(s.Quantity)                                         AS total_units_sold,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)           AS total_revenue,
  ROUND(SUM(s.Quantity * s.Unit_sale_price)
      - SUM(s.Quantity * p.`Unit cost`), 2)               AS gross_profit,
  ROUND(
    (SUM(s.Quantity * s.Unit_sale_price)
   - SUM(s.Quantity * p.`Unit cost`))
  / NULLIF(SUM(s.Quantity * s.Unit_sale_price), 0) * 100
  , 2)                                                    AS margin_pct
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
GROUP BY 1
ORDER BY total_revenue DESC;


-- ============================================================
-- 3. TOP 10 BEST-SELLING PRODUCTS
-- ============================================================
-- Business Question: What are GoExplore's star products?

SELECT
  p.Product,
  p.`Product line`,
  p.`Product type`,
  SUM(s.Quantity)                                  AS units_sold,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)    AS revenue,
  ROUND(AVG(s.Unit_sale_price), 2)                 AS avg_sale_price
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
GROUP BY 1, 2, 3
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 4. DISCOUNT / PRICE EROSION ANALYSIS
-- ============================================================
-- Business Question: How much discount is being given?
-- Which products have the deepest discounts?

SELECT
  p.`Product line`,
  p.Product,
  ROUND(AVG(s.Unit_price), 2)                          AS avg_list_price,
  ROUND(AVG(s.Unit_sale_price), 2)                     AS avg_sale_price,
  ROUND(AVG(s.Unit_price - s.Unit_sale_price), 2)      AS avg_discount_amt,
  ROUND(
    AVG((s.Unit_price - s.Unit_sale_price)
      / NULLIF(s.Unit_price, 0)) * 100
  , 2)                                                  AS avg_discount_pct
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
GROUP BY 1, 2
ORDER BY avg_discount_pct DESC;


-- ============================================================
-- 5. COUNTRY / REGIONAL PERFORMANCE
-- ============================================================
-- Business Question: Which countries contribute the most?

SELECT
  r.Country,
  COUNT(DISTINCT s.Retailer_code)                   AS num_retailers,
  SUM(s.Quantity)                                   AS total_units,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)     AS total_revenue,
  ROUND(SUM(s.Quantity * s.Unit_sale_price)
      - SUM(s.Quantity * p.`Unit cost`), 2)         AS gross_profit
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Retailers`    r
  ON s.Retailer_code = r.`Retailer code`
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
GROUP BY 1
ORDER BY total_revenue DESC;


-- ============================================================
-- 6. RETAILER TYPE / CHANNEL ANALYSIS
-- ============================================================
-- Business Question: Which retail channel performs best?

SELECT
  r.Type                                             AS retailer_type,
  COUNT(DISTINCT s.Retailer_code)                    AS num_retailers,
  SUM(s.Quantity)                                    AS total_units,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)      AS total_revenue,
  ROUND(AVG(s.Quantity * s.Unit_sale_price), 2)      AS avg_order_value
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Retailers`    r
  ON s.Retailer_code = r.`Retailer code`
GROUP BY 1
ORDER BY total_revenue DESC;


-- ============================================================
-- 7. TOP 10 RETAILERS BY REVENUE
-- ============================================================
-- Business Question: Who are the key accounts?

SELECT
  r.`Retailer name`,
  r.Country,
  r.Type,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)      AS total_revenue,
  SUM(s.Quantity)                                    AS total_units,
  COUNT(*)                                           AS num_transactions
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Retailers`    r
  ON s.Retailer_code = r.`Retailer code`
GROUP BY 1, 2, 3
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 8. ORDER METHOD BREAKDOWN
-- ============================================================
-- Business Question: How do customers prefer to order?

SELECT
  m.`Order method type`                             AS order_method,
  COUNT(*)                                          AS num_orders,
  SUM(s.Quantity)                                   AS total_units,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)     AS total_revenue,
  ROUND(AVG(s.Quantity * s.Unit_sale_price), 2)     AS avg_order_value
FROM `goexplore-505409.goexplore.daily_sales`   s
JOIN `goexplore-505409.goexplore.methods`       m
  ON s.Order_method_code = m.`Order method code`
GROUP BY 1
ORDER BY total_revenue DESC;


-- ============================================================
-- 9. ORDER METHOD TREND OVER YEARS (Digital vs Traditional)
-- ============================================================
-- Business Question: Are digital channels (Web, E-mail)
-- growing vs traditional (Fax, Mail, Telephone)?

SELECT
  EXTRACT(YEAR FROM s.Date)                          AS year,
  m.`Order method type`                              AS order_method,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)      AS revenue
FROM `goexplore-505409.goexplore.daily_sales`   s
JOIN `goexplore-505409.goexplore.methods`       m
  ON s.Order_method_code = m.`Order method code`
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- ============================================================
-- 10. SEASONALITY ANALYSIS (Monthly Revenue Pattern)
-- ============================================================
-- Business Question: Which months are peak sales periods?

SELECT
  EXTRACT(MONTH FROM Date)                           AS month_num,
  FORMAT_DATE('%B', Date)                            AS month_name,
  ROUND(SUM(Quantity * Unit_sale_price), 2)          AS total_revenue,
  ROUND(AVG(Quantity * Unit_sale_price), 2)          AS avg_daily_revenue
FROM `goexplore-505409.goexplore.daily_sales`
GROUP BY 1, 2
ORDER BY 1;


-- ============================================================
-- 11. PRODUCT LINE × COUNTRY CROSS ANALYSIS
-- ============================================================
-- Business Question: Which product lines sell best where?

SELECT
  r.Country,
  p.`Product line`,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)   AS revenue,
  SUM(s.Quantity)                                 AS units_sold
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
JOIN `goexplore-505409.goexplore.Retailers`    r
  ON s.Retailer_code = r.`Retailer code`
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- ============================================================
-- 12. SLOW-MOVING / LOW-REVENUE PRODUCTS
-- ============================================================
-- Business Question: Which products need promotion or removal?

SELECT
  p.Product,
  p.`Product line`,
  p.`Product type`,
  SUM(s.Quantity)                                  AS units_sold,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)    AS revenue
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN `goexplore-505409.goexplore.Products`     p
  ON s.Product_number = p.`Product number`
GROUP BY 1, 2, 3
ORDER BY revenue ASC
LIMIT 10;


-- ============================================================
-- 13. RETAILER COHORT – NEW vs RETURNING
-- ============================================================
-- Business Question: Are we retaining retailers year-over-year?

WITH retailer_first_year AS (
  SELECT
    Retailer_code,
    MIN(EXTRACT(YEAR FROM Date)) AS first_year
  FROM `goexplore-505409.goexplore.daily_sales`
  GROUP BY 1
)
SELECT
  EXTRACT(YEAR FROM s.Date)                            AS year,
  CASE
    WHEN EXTRACT(YEAR FROM s.Date) = rf.first_year
    THEN 'New Retailer'
    ELSE 'Returning Retailer'
  END                                                  AS retailer_status,
  COUNT(DISTINCT s.Retailer_code)                      AS num_retailers,
  ROUND(SUM(s.Quantity * s.Unit_sale_price), 2)        AS revenue
FROM `goexplore-505409.goexplore.daily_sales`  s
JOIN retailer_first_year rf
  ON s.Retailer_code = rf.Retailer_code
GROUP BY 1, 2
ORDER BY 1, 2;


-- ============================================================
-- 14. DAY-OF-WEEK SALES PATTERN
-- ============================================================
-- Business Question: Which days have highest order volume?

SELECT
  FORMAT_DATE('%A', Date)                              AS day_of_week,
  EXTRACT(DAYOFWEEK FROM Date)                         AS day_num,
  COUNT(*)                                             AS num_transactions,
  SUM(Quantity)                                        AS total_units,
  ROUND(SUM(Quantity * Unit_sale_price), 2)            AS total_revenue,
  ROUND(AVG(Quantity * Unit_sale_price), 2)            AS avg_order_value
FROM `goexplore-505409.goexplore.daily_sales`
GROUP BY 1, 2
ORDER BY 2;


-- ============================================================
-- END OF PLAYBOOK
-- ============================================================
