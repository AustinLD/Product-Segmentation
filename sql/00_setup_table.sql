-- 00_setup_table.sql
-- Online Retail II staging table. Load both source sheets (2009-2010 and 2010-2011)
-- into this single table before running the analysis scripts.
-- Dialect: PostgreSQL. Adjust types lightly for SQLite/MySQL if needed.

DROP TABLE IF EXISTS retail;

CREATE TABLE retail (
    invoice       VARCHAR(20),      -- prefix 'C' marks a cancellation/return
    stock_code    VARCHAR(20),
    description   VARCHAR(255),
    quantity      INTEGER,          -- negative on returns
    invoice_date  TIMESTAMP,
    price         NUMERIC(10,2),    -- unit price
    customer_id   INTEGER,          -- null on many guest rows
    country       VARCHAR(60)
);

-- Load both sheets here (\copy from CSV, or your loader of choice), then continue.

-- A cleaned view used by every downstream script:
--  * keep only real stock codes (exclude postage, fees, manual adjustments)
--  * a sale is a positive-quantity, positive-price line on a non-'C' invoice
DROP VIEW IF EXISTS sales_lines;
CREATE VIEW sales_lines AS
SELECT *
FROM   retail
WHERE  stock_code ~ '^[0-9]{5}[A-Za-z]?$'   -- 5 digits, optional trailing letter
  AND  quantity  > 0
  AND  price     > 0
  AND  invoice NOT LIKE 'C%';

DROP VIEW IF EXISTS return_lines;
CREATE VIEW return_lines AS
SELECT *
FROM   retail
WHERE  stock_code ~ '^[0-9]{5}[A-Za-z]?$'
  AND  (quantity < 0 OR invoice LIKE 'C%');
