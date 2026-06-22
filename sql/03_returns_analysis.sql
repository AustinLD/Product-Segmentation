-- 03_returns_analysis.sql
-- Which SKUs lose the most to returns. Returns are a clustering feature, so this
-- script sanity-checks that the return_rate values are sane and surfaces the
-- worst offenders for the case-study narrative.

WITH sold AS (
    SELECT stock_code, SUM(quantity) AS units_sold,
           SUM(quantity*price) AS revenue
    FROM   sales_lines
    GROUP  BY stock_code
),
returned AS (
    SELECT stock_code, SUM(ABS(quantity)) AS units_returned
    FROM   return_lines
    GROUP  BY stock_code
)
SELECT s.stock_code,
       s.units_sold,
       COALESCE(r.units_returned, 0)                                   AS units_returned,
       ROUND(100.0 * COALESCE(r.units_returned,0)
             / NULLIF(s.units_sold,0), 1)                              AS return_pct,
       s.revenue
FROM   sold s
LEFT   JOIN returned r ON r.stock_code = s.stock_code
WHERE  s.units_sold >= 50               -- ignore trivial-volume noise
ORDER  BY return_pct DESC
LIMIT  50;
