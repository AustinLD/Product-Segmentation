-- 01_sku_aggregation.sql
-- One row per SKU with the same features the clustering notebook builds.
-- This is the SQL mirror of the notebook's feature engineering, useful for
-- validating the Python numbers and for feeding Power BI directly.

WITH sales AS (
    SELECT stock_code,
           SUM(quantity)               AS total_units,
           SUM(quantity * price)       AS total_revenue,
           COUNT(DISTINCT invoice)     AS num_orders,
           COUNT(DISTINCT customer_id) AS num_customers,
           MIN(invoice_date)           AS first_sold,
           MAX(invoice_date)           AS last_sold
    FROM   sales_lines
    GROUP  BY stock_code
),
returns AS (
    SELECT stock_code,
           SUM(ABS(quantity)) AS returned_units
    FROM   return_lines
    GROUP  BY stock_code
),
monthly AS (   -- monthly units per SKU, for the seasonality feature
    SELECT stock_code,
           DATE_TRUNC('month', invoice_date) AS ym,
           SUM(quantity)                      AS units
    FROM   sales_lines
    GROUP  BY stock_code, DATE_TRUNC('month', invoice_date)
),
seasonality AS (
    SELECT stock_code,
           STDDEV_POP(units) / NULLIF(AVG(units), 0) AS demand_cv
    FROM   monthly
    GROUP  BY stock_code
),
top_customer AS (   -- revenue share of each SKU's single largest customer
    SELECT stock_code,
           MAX(cust_rev) / NULLIF(SUM(cust_rev), 0) AS top_customer_share
    FROM (
        SELECT stock_code, customer_id,
               SUM(quantity * price) AS cust_rev
        FROM   sales_lines
        WHERE  customer_id IS NOT NULL
        GROUP  BY stock_code, customer_id
    ) c
    GROUP BY stock_code
)
SELECT s.stock_code,
       s.total_revenue,
       s.total_units,
       s.num_orders,
       s.num_customers,
       ROUND(s.total_revenue / NULLIF(s.total_units, 0), 2)        AS avg_unit_price,
       ROUND(COALESCE(r.returned_units, 0)
             / NULLIF(s.total_units, 0)::numeric, 4)                AS return_rate,
       ROUND(sea.demand_cv, 4)                                      AS seasonality,
       ROUND(tc.top_customer_share, 4)                             AS customer_concentration
FROM   sales s
LEFT   JOIN returns      r   ON r.stock_code   = s.stock_code
LEFT   JOIN seasonality  sea ON sea.stock_code = s.stock_code
LEFT   JOIN top_customer tc  ON tc.stock_code  = s.stock_code
ORDER  BY s.total_revenue DESC;
