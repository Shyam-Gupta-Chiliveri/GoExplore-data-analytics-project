WITH base AS (
  SELECT
    -- DATE
    ds.Date                                 AS date,
    EXTRACT(YEAR FROM ds.Date)              AS year,
    EXTRACT(MONTH FROM ds.Date)             AS month,
    FORMAT_DATE('%B', ds.Date)              AS month_name,
    EXTRACT(QUARTER FROM ds.Date)           AS quarter,
    FORMAT_DATE('%Y-%m', ds.Date)           AS year_month,
    FORMAT_DATE('%A', ds.Date)              AS day_of_week,

    -- RETAILER
    r.`Retailer name`                       AS retailer_name,
    r.Type                                  AS retailer_type,
    r.Country                               AS country,
    CASE
      WHEN r.Country IN (
        'France','Switzerland','Germany','Sweden',
        'Netherlands','Italy','Spain','Denmark',
        'Finland','United Kingdom','Belgium','Austria'
      ) THEN 'Europe'
      WHEN r.Country IN (
        'Canada','United States','Mexico'
      ) THEN 'North America'
      WHEN r.Country IN (
        'Japan','Korea','Singapore','China'
      ) THEN 'East Asia'
      WHEN r.Country = 'Australia' THEN 'South Pacific'
      WHEN r.Country = 'Brazil'   THEN 'South America'
      ELSE 'Other'
    END                                     AS region,

    -- PRODUCT
    p.Product                               AS product,
    p.`Product line`                        AS product_line,
    p.`Product type`                        AS product_type,
    p.`Product brand`                       AS product_brand,

    -- ORDER METHOD
    m.`Order method type`                   AS order_method,
    CASE
      WHEN m.`Order method type`
           IN ('Web','E-mail')    THEN 'Digital'
      WHEN m.`Order method type`
           IN ('Telephone','Fax','Mail') THEN 'Traditional'
      WHEN m.`Order method type`
           = 'Sales visit'        THEN 'Field Sales'
      ELSE 'Other'
    END                                     AS channel_type,

    -- RAW NUMBERS
    ds.Quantity                             AS quantity,
    ds.Unit_sale_price                      AS unit_sale_price,
    ds.Unit_price                           AS unit_list_price,
    p.`Unit cost`                           AS unit_cost,

    -- ROW LEVEL CALCULATIONS
    ds.Quantity * ds.Unit_sale_price        AS row_revenue,
    ds.Quantity * p.`Unit cost`             AS row_cost,
    ds.Unit_price - ds.Unit_sale_price      AS row_discount_amt,
    ds.Retailer_code                        AS retailer_code,
    ds.Product_number                       AS product_number

  FROM `goexplore-505409.goexplore.daily_sales`  ds
  JOIN `goexplore-505409.goexplore.Retailers`    r
    ON ds.Retailer_code = r.`Retailer code`
  JOIN `goexplore-505409.goexplore.Products`     p
    ON ds.Product_number = p.`Product number`
  JOIN `goexplore-505409.goexplore.methods`      m
    ON ds.Order_method_code = m.`Order method code`
),

aggregated AS (
  SELECT
    -- DATE DIMENSIONS
    date,
    year,
    month,
    month_name,
    quarter,
    year_month,
    day_of_week,

    -- RETAILER DIMENSIONS
    retailer_name,
    retailer_type,
    country,
    region,

    -- PRODUCT DIMENSIONS
    product,
    product_line,
    product_type,
    product_brand,

    -- ORDER DIMENSIONS
    order_method,
    channel_type,

    -- ALL KPIs
    COUNT(*)                                AS total_transactions,
    COUNT(DISTINCT retailer_code)           AS num_retailers,
    COUNT(DISTINCT product_number)          AS num_products,
    SUM(quantity)                           AS total_units,

    ROUND(SUM(row_revenue), 2)              AS total_revenue,
    ROUND(SUM(row_cost), 2)                 AS total_cost,
    ROUND(SUM(row_revenue)
        - SUM(row_cost), 2)                 AS gross_profit,

    ROUND(
      (SUM(row_revenue) - SUM(row_cost))
      / NULLIF(SUM(row_revenue), 0)
      * 100, 2)                             AS profit_margin_pct,

    ROUND(AVG(row_revenue), 2)              AS avg_order_value,
    ROUND(AVG(unit_sale_price), 2)          AS avg_sale_price,
    ROUND(AVG(unit_list_price), 2)          AS avg_list_price,
    ROUND(AVG(row_discount_amt), 2)         AS avg_discount_amt,

    ROUND(AVG(row_discount_amt
      / NULLIF(unit_list_price, 0))
      * 100, 2)                             AS avg_discount_pct,

    ROUND(AVG(unit_sale_price
        - unit_cost), 2)                    AS avg_profit_per_unit,
    ROUND(AVG(unit_sale_price), 2)          AS avg_revenue_per_unit

  FROM base
  GROUP BY
    date,
    year, month, month_name, quarter,
    year_month, day_of_week,
    retailer_name, retailer_type,
    country, region,
    product, product_line,
    product_type, product_brand,
    order_method, channel_type
)

SELECT
  *,
  CASE
    WHEN avg_discount_pct = 0    THEN 'No discount'
    WHEN avg_discount_pct <= 10  THEN 'Low 1-10%'
    WHEN avg_discount_pct <= 25  THEN 'Medium 11-25%'
    ELSE                              'High 25%+'
  END                                       AS discount_tier,

  CASE
    WHEN profit_margin_pct >= 50 THEN 'High margin'
    WHEN profit_margin_pct >= 30 THEN 'Medium margin'
    ELSE                              'Low margin'
  END                                       AS margin_tier,

  CASE
    WHEN total_units >= 1000 THEN 'Bulk'
    WHEN total_units >= 500  THEN 'Large'
    WHEN total_units >= 100  THEN 'Medium'
    ELSE                          'Small'
  END                                       AS order_size_tier

FROM aggregated
