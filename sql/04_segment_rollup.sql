-- 04_segment_rollup.sql
-- After the notebook assigns each SKU a cluster, export stock_code + cluster +
-- segment_name to a table `sku_clusters`, then this rollup produces the
-- segment-level profile that drives the Power BI table and treemap.
--
-- Expected helper table:
--   CREATE TABLE sku_clusters (stock_code VARCHAR(20), cluster INT, segment_name VARCHAR(40));

WITH features AS (
    SELECT s.stock_code,
           SUM(s.quantity * s.price)       AS revenue,
           SUM(s.quantity)                 AS units,
           COUNT(DISTINCT s.invoice)       AS orders,
           COUNT(DISTINCT s.customer_id)   AS customers,
           SUM(s.quantity*s.price)/NULLIF(SUM(s.quantity),0) AS avg_price
    FROM   sales_lines s
    GROUP  BY s.stock_code
)
SELECT c.segment_name,
       COUNT(*)                                  AS n_skus,
       ROUND(SUM(f.revenue), 0)                  AS segment_revenue,
       ROUND(100.0 * SUM(f.revenue)
             / SUM(SUM(f.revenue)) OVER (), 1)    AS pct_of_revenue,
       ROUND(AVG(f.avg_price), 2)                AS avg_unit_price,
       ROUND(AVG(f.orders), 1)                   AS avg_orders_per_sku,
       ROUND(AVG(f.customers), 1)                AS avg_customers_per_sku
FROM   sku_clusters c
JOIN   features f ON f.stock_code = c.stock_code
GROUP  BY c.segment_name
ORDER  BY segment_revenue DESC;
