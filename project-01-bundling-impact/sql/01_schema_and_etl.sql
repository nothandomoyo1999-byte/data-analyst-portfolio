/* =====================================================================
   PROJECT 01 — Bundling Strategy Impact Analysis
   Centralized reporting schema (star schema) + data validation rules
   Target: SQL Server / PostgreSQL-compatible syntax (adjust types as needed)
   ===================================================================== */

-- -------------------------------------------------------------------
-- 0. STAGING: raw load target for the daily Excel exports
--    (loaded via Power Query / SSIS / pandas.to_sql — no constraints
--     here on purpose, this layer just mirrors the source file)
-- -------------------------------------------------------------------
CREATE TABLE staging_daily_sales (
    sale_date       VARCHAR(20),      -- raw text on purpose; source dates are inconsistent
    product_name    VARCHAR(50),
    quantity_sold   VARCHAR(20),
    unit_price      VARCHAR(20),
    unit_cost       VARCHAR(20),
    is_bundle       VARCHAR(5),
    source_file     VARCHAR(100),
    load_timestamp  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------------
-- 1. DIMENSION TABLES
-- -------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,        -- yyyymmdd
    full_date       DATE NOT NULL,
    day_of_week     VARCHAR(10) NOT NULL,
    month_name      VARCHAR(10) NOT NULL,
    quarter         TINYINT NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    year            SMALLINT NOT NULL,
    period_label    VARCHAR(20) NOT NULL,    -- e.g. 'Jan 2024 (Before)', 'Dec 2023 (After)'
    is_promo_period BIT NOT NULL DEFAULT 0
);

CREATE TABLE dim_product (
    product_key     INT IDENTITY(1,1) PRIMARY KEY,
    product_name    VARCHAR(50) NOT NULL UNIQUE,
    product_type    VARCHAR(20) NOT NULL CHECK (product_type IN ('Individual','Bundle')),
    category        VARCHAR(30) NOT NULL
);

-- -------------------------------------------------------------------
-- 2. FACT TABLE — the single source of truth for reporting
--    Constraints enforce the data-integrity checks that used to be
--    done manually in Excel.
-- -------------------------------------------------------------------
CREATE TABLE fact_sales (
    sale_id         INT IDENTITY(1,1) PRIMARY KEY,
    date_key        INT NOT NULL REFERENCES dim_date(date_key),
    product_key     INT NOT NULL REFERENCES dim_product(product_key),
    quantity_sold   INT NOT NULL CHECK (quantity_sold >= 0),
    unit_price      DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    unit_cost       DECIMAL(10,2) NOT NULL CHECK (unit_cost > 0 AND unit_cost < unit_price),
    revenue         AS (quantity_sold * unit_price) PERSISTED,
    cost            AS (quantity_sold * unit_cost) PERSISTED,
    profit          AS (quantity_sold * (unit_price - unit_cost)) PERSISTED,
    UNIQUE (date_key, product_key)          -- one row per product per day: no duplicate loads
);

-- -------------------------------------------------------------------
-- 3. ETL: staging -> fact, with explicit validation / rejection
-- -------------------------------------------------------------------

-- 3a. Quarantine rows that fail basic sanity checks instead of
--     silently dropping or loading bad data.
CREATE TABLE staging_rejects (
    staging_row     VARCHAR(500),
    reject_reason   VARCHAR(200),
    rejected_at     DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO staging_rejects (staging_row, reject_reason)
SELECT CONCAT(sale_date, ' | ', product_name, ' | ', quantity_sold),
       CASE
           WHEN TRY_CAST(sale_date AS DATE) IS NULL THEN 'Unparseable date'
           WHEN TRY_CAST(quantity_sold AS INT) IS NULL OR TRY_CAST(quantity_sold AS INT) < 0 THEN 'Invalid quantity'
           WHEN TRY_CAST(unit_price AS DECIMAL(10,2)) IS NULL OR TRY_CAST(unit_price AS DECIMAL(10,2)) <= 0 THEN 'Invalid price'
           WHEN TRY_CAST(unit_cost AS DECIMAL(10,2)) IS NULL OR TRY_CAST(unit_cost AS DECIMAL(10,2)) <= 0 THEN 'Invalid cost'
           WHEN TRY_CAST(unit_cost AS DECIMAL(10,2)) >= TRY_CAST(unit_price AS DECIMAL(10,2)) THEN 'Cost >= price (margin error)'
       END
FROM staging_daily_sales
WHERE TRY_CAST(sale_date AS DATE) IS NULL
   OR TRY_CAST(quantity_sold AS INT) IS NULL OR TRY_CAST(quantity_sold AS INT) < 0
   OR TRY_CAST(unit_price AS DECIMAL(10,2)) IS NULL OR TRY_CAST(unit_price AS DECIMAL(10,2)) <= 0
   OR TRY_CAST(unit_cost AS DECIMAL(10,2)) IS NULL OR TRY_CAST(unit_cost AS DECIMAL(10,2)) <= 0
   OR TRY_CAST(unit_cost AS DECIMAL(10,2)) >= TRY_CAST(unit_price AS DECIMAL(10,2));

-- 3b. Load only clean rows into the fact table
INSERT INTO fact_sales (date_key, product_key, quantity_sold, unit_price, unit_cost)
SELECT
    CAST(FORMAT(TRY_CAST(s.sale_date AS DATE), 'yyyyMMdd') AS INT) AS date_key,
    p.product_key,
    TRY_CAST(s.quantity_sold AS INT),
    TRY_CAST(s.unit_price AS DECIMAL(10,2)),
    TRY_CAST(s.unit_cost AS DECIMAL(10,2))
FROM staging_daily_sales s
JOIN dim_product p ON p.product_name = s.product_name
WHERE TRY_CAST(s.sale_date AS DATE) IS NOT NULL
  AND TRY_CAST(s.quantity_sold AS INT) >= 0
  AND TRY_CAST(s.unit_price AS DECIMAL(10,2)) > 0
  AND TRY_CAST(s.unit_cost AS DECIMAL(10,2)) > 0
  AND TRY_CAST(s.unit_cost AS DECIMAL(10,2)) < TRY_CAST(s.unit_price AS DECIMAL(10,2));

-- -------------------------------------------------------------------
-- 4. REPORTING VIEWS — this is what Power BI connects to,
--    so the dashboard never touches raw/staging data.
-- -------------------------------------------------------------------
CREATE VIEW vw_monthly_performance AS
SELECT
    d.period_label,
    p.product_type,
    SUM(f.quantity_sold)  AS total_units,
    SUM(f.revenue)         AS total_revenue,
    SUM(f.cost)             AS total_cost,
    SUM(f.profit)            AS total_profit,
    ROUND(SUM(f.profit) * 100.0 / NULLIF(SUM(f.revenue), 0), 1) AS margin_pct
FROM fact_sales f
JOIN dim_date d    ON d.date_key = f.date_key
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY d.period_label, p.product_type;

CREATE VIEW vw_period_growth AS
SELECT
    curr.period_label AS after_period,
    prev.period_label AS before_period,
    curr.total_revenue AS revenue_after,
    prev.total_revenue AS revenue_before,
    ROUND((curr.total_revenue - prev.total_revenue) * 100.0 / NULLIF(prev.total_revenue, 0), 1) AS revenue_growth_pct,
    ROUND((curr.total_profit - prev.total_profit) * 100.0 / NULLIF(prev.total_profit, 0), 1) AS profit_growth_pct
FROM vw_monthly_performance curr
JOIN vw_monthly_performance prev ON 1 = 1; -- paired manually per comparison window in BI layer
