-- 02_pareto_abc.sql
-- The "bestseller vs. the rest" baseline the project argues against.
-- Ranks SKUs by revenue, builds a running cumulative revenue share with a
-- window function, and assigns ABC classes (A = top 80% of revenue, B = next 15%,
-- C = last 5%). The case study contrasts these blunt classes with the clusters.

WITH sku_rev AS (
    SELECT stock_code,
           SUM(quantity * price) AS revenue
    FROM   sales_lines
    GROUP  BY stock_code
),
ranked AS (
    SELECT stock_code,
           revenue,
           SUM(revenue) OVER ()                                   AS total_rev,
           SUM(revenue) OVER (ORDER BY revenue DESC
                              ROWS UNBOUNDED PRECEDING)           AS cum_rev,
           ROW_NUMBER()  OVER (ORDER BY revenue DESC)             AS rev_rank,
           COUNT(*)      OVER ()                                  AS n_skus
    FROM   sku_rev
)
SELECT stock_code,
       revenue,
       rev_rank,
       ROUND(100.0 * rev_rank / n_skus, 1)        AS sku_percentile,
       ROUND(100.0 * cum_rev / total_rev, 1)      AS cum_revenue_pct,
       CASE
           WHEN cum_rev / total_rev <= 0.80 THEN 'A'
           WHEN cum_rev / total_rev <= 0.95 THEN 'B'
           ELSE 'C'
       END                                        AS abc_class
FROM   ranked
ORDER  BY rev_rank;
