-- ============================================================
-- PHASE 4 — ANALYSIS LAYER
-- STEP 26 — BASELINE METRICS
-- ============================================================

SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS overall_margin_pct ,
    COUNT(DISTINCT order_id) AS order_count
FROM fact_orders;
-- ============================================================
-- STEP 27 — REGIONAL PERFORMANCE
-- ============================================================

SELECT
    l.region,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct
FROM fact_orders f
JOIN dim_locations l
    ON f.location_id = l.location_id
GROUP BY l.region
ORDER BY total_sales DESC;
-- ============================================================
-- STEP 28 — CATEGORY PERFORMANCE
-- ============================================================

SELECT
    p.category,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct
FROM fact_orders f
JOIN dim_products p
    ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;
-- ============================================================
-- STEP 28B — SUB-CATEGORY PERFORMANCE
-- ============================================================

SELECT
    p.sub_category,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct
FROM fact_orders f
JOIN dim_products p
    ON f.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_sales DESC;
-- STEP 29 — CHECK DISCOUNT RANGE

SELECT
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    AVG(discount) AS avg_discount
FROM fact_orders;
-- ============================================================
-- STEP 29 — DISCOUNT VS. MARGIN
-- ============================================================

WITH discount_bands AS (
    SELECT
        discount,
        sales,
        profit,
        CASE
            WHEN discount = 0 THEN '0%'
            WHEN discount <= 0.10 THEN '1-10%'
            WHEN discount <= 0.20 THEN '11-20%'
            WHEN discount <= 0.25 THEN '21-25%'
            ELSE '>25%'
        END AS discount_band
    FROM fact_orders
)
SELECT
    discount_band,
    COUNT(*) AS order_lines,
    ROUND(
        AVG(profit / NULLIF(sales, 0)) * 100,
        2
    ) AS average_margin_pct
FROM discount_bands
GROUP BY discount_band
ORDER BY
    CASE discount_band
        WHEN '0%' THEN 1
        WHEN '1-10%' THEN 2
        WHEN '11-20%' THEN 3
        WHEN '21-25%' THEN 4
        WHEN '>25%' THEN 5
    END;
	SELECT
    DATE_TRUNC('month', date) AS month,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM fact_orders
GROUP BY DATE_TRUNC('month', date)
ORDER BY month;
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', date) AS month,
        SUM(sales) AS total_sales
    FROM fact_orders
    GROUP BY DATE_TRUNC('month', date)
)

SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales
FROM monthly_sales
ORDER BY month;
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', date) AS month,
        SUM(sales) AS total_sales
    FROM fact_orders
    GROUP BY DATE_TRUNC('month', date)
),

sales_with_previous AS (
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    month,
    total_sales,
    previous_month_sales,
    ROUND(
        (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct
FROM sales_with_previous
ORDER BY month;
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', date) AS month,
        SUM(sales) AS total_sales
    FROM fact_orders
    GROUP BY DATE_TRUNC('month', date)
),

sales_with_previous AS (
    SELECT
        month,
        total_sales,

        LAG(total_sales, 1) OVER (ORDER BY month)
            AS previous_month_sales,

        LAG(total_sales, 12) OVER (ORDER BY month)
            AS previous_year_sales

    FROM monthly_sales
)

SELECT
    month,
    total_sales,
    previous_month_sales,
    ROUND(
        (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct,

    previous_year_sales,

    ROUND(
        (total_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS yoy_growth_pct

FROM sales_with_previous
ORDER BY month;
-- ============================================================
-- STEP 31 — RUNNING TOTALS
-- ============================================================

WITH monthly_profit AS (
    SELECT
        DATE_TRUNC('month', date) AS month,
        SUM(profit) AS monthly_profit
    FROM fact_orders
    GROUP BY DATE_TRUNC('month', date)
)

SELECT
    month,
    monthly_profit,
    SUM(monthly_profit) OVER (
        ORDER BY month
    ) AS cumulative_profit
FROM monthly_profit
ORDER BY month;
-- STEP 31B — CUMULATIVE PROFIT BY YEAR

WITH monthly_profit AS (
    SELECT
        DATE_TRUNC('month', date) AS month,
        SUM(profit) AS monthly_profit
    FROM fact_orders
    GROUP BY DATE_TRUNC('month', date)
)

SELECT
    month,
    monthly_profit,
    SUM(monthly_profit) OVER (
        PARTITION BY EXTRACT(YEAR FROM month)
        ORDER BY month
    ) AS yearly_cumulative_profit
FROM monthly_profit
ORDER BY month;
-- ============================================================
-- STEP 32 — CATEGORY RANKING WITHIN REGION
-- ============================================================

WITH category_margin AS (
    SELECT
        l.region,
        p.category,
        SUM(f.sales) AS total_sales,
        SUM(f.profit) AS total_profit,
        ROUND(
            SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
            2
        ) AS margin_pct
    FROM fact_orders f
    JOIN dim_locations l
        ON f.location_id = l.location_id
    JOIN dim_products p
        ON f.product_id = p.product_id
    GROUP BY
        l.region,
        p.category
)

SELECT
    region,
    category,
    total_sales,
    total_profit,
    margin_pct,
    RANK() OVER (
        PARTITION BY region
        ORDER BY margin_pct DESC
    ) AS margin_rank
FROM category_margin
ORDER BY region, margin_rank;
-- ============================================================
-- STEP 33 — CUSTOMER-LEVEL ANALYSIS
-- Create customer/order bridge
-- ============================================================


SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT customer_id) AS unique_customers
FROM customer_orders;
SELECT COUNT(*) AS unmatched_orders
FROM fact_orders f
LEFT JOIN customer_orders c
    ON f.order_id = c.order_id
WHERE c.order_id IS NULL;
-- ============================================================
-- STEP 33A — REPEAT PURCHASE RATE
-- ============================================================

WITH customer_orders_count AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM customer_orders
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        COUNT(*) FILTER (WHERE order_count > 1)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS repeat_purchase_rate_pct
FROM customer_orders_count;
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM customer_orders;
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS order_count
FROM customer_orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 10;
-- ============================================================
-- STEP 33B — AVERAGE ORDER VALUE BY SEGMENT
-- ============================================================

SELECT
    c.segment,
    COUNT(DISTINCT c.order_id) AS total_orders,
    SUM(f.sales) AS total_sales,
    ROUND(
        SUM(f.sales) / NULLIF(COUNT(DISTINCT c.order_id), 0),
        2
    ) AS average_order_value
FROM fact_orders f
JOIN customer_orders c
    ON f.order_id = c.order_id
GROUP BY c.segment
ORDER BY average_order_value DESC;
-- ============================================================
-- STEP 34 — CUSTOMERS ABOVE REGIONAL AVERAGE AOV
-- ============================================================

WITH customer_aov AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.segment,
        l.region,
        SUM(f.sales) / NULLIF(COUNT(DISTINCT f.order_id), 0) AS customer_aov
    FROM fact_orders f
    JOIN customer_orders c
        ON f.order_id = c.order_id
    JOIN dim_locations l
        ON f.location_id = l.location_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.segment,
        l.region
),

regional_aov AS (
    SELECT
        *,
        AVG(customer_aov) OVER (
            PARTITION BY region
        ) AS regional_avg_aov
    FROM customer_aov
)

SELECT
    customer_id,
    customer_name,
    segment,
    region,
    ROUND(customer_aov, 2) AS customer_aov,
    ROUND(regional_avg_aov, 2) AS regional_avg_aov
FROM regional_aov
WHERE customer_aov > regional_avg_aov
ORDER BY region, customer_aov DESC;
-- ============================================================
-- STEP 35A — REDUCE DISCOUNT LIST
-- ============================================================

WITH category_metrics AS (
    SELECT
        p.category,
        AVG(f.discount) * 100 AS avg_discount_pct,
        SUM(f.sales) AS total_sales,
        SUM(f.profit) AS total_profit,
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100 AS margin_pct
    FROM fact_orders f
    JOIN dim_products p
        ON f.product_id = p.product_id
    GROUP BY p.category
),

overall_margin AS (
    SELECT
        SUM(profit) / NULLIF(SUM(sales), 0) * 100 AS overall_margin_pct
    FROM fact_orders
)

SELECT
    cm.category,
    ROUND(cm.avg_discount_pct, 2) AS avg_discount_pct,
    ROUND(cm.margin_pct, 2) AS margin_pct,
    ROUND(om.overall_margin_pct, 2) AS overall_margin_pct,
    ROUND(cm.total_sales, 2) AS total_sales
FROM category_metrics cm
CROSS JOIN overall_margin om
WHERE cm.avg_discount_pct > 25
  AND cm.margin_pct < om.overall_margin_pct
ORDER BY cm.margin_pct ASC;
-- ============================================================
-- STEP 35B — INVEST MORE LIST
-- ============================================================

WITH monthly_region_sales AS (
    SELECT
        l.region,
        DATE_TRUNC('month', f.date) AS month,
        SUM(f.sales) AS monthly_sales
    FROM fact_orders f
    JOIN dim_locations l
        ON f.location_id = l.location_id
    GROUP BY
        l.region,
        DATE_TRUNC('month', f.date)
),

region_trend AS (
    SELECT
        region,
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (
            PARTITION BY region
            ORDER BY month
        ) AS previous_month_sales
    FROM monthly_region_sales
),

latest_region_trend AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY month DESC
        ) AS rn
    FROM region_trend
),

region_metrics AS (
    SELECT
        l.region,
        AVG(f.discount) * 100 AS avg_discount_pct,
        SUM(f.sales) AS total_sales,
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100 AS margin_pct
    FROM fact_orders f
    JOIN dim_locations l
        ON f.location_id = l.location_id
    GROUP BY l.region
),

overall_margin AS (
    SELECT
        SUM(profit) / NULLIF(SUM(sales), 0) * 100 AS overall_margin_pct
    FROM fact_orders
)

SELECT
    rm.region,
    ROUND(rm.avg_discount_pct, 2) AS avg_discount_pct,
    ROUND(rm.margin_pct, 2) AS margin_pct,
    ROUND(om.overall_margin_pct, 2) AS overall_margin_pct,
    ROUND(rm.total_sales, 2) AS total_sales,
    ROUND(lrt.monthly_sales, 2) AS latest_month_sales,
    ROUND(lrt.previous_month_sales, 2) AS previous_month_sales
FROM region_metrics rm
CROSS JOIN overall_margin om
JOIN latest_region_trend lrt
    ON rm.region = lrt.region
   AND lrt.rn = 1
WHERE rm.avg_discount_pct <= 10
  AND rm.margin_pct > om.overall_margin_pct
  AND lrt.monthly_sales > lrt.previous_month_sales
ORDER BY rm.margin_pct DESC;
SELECT
    l.region,
    ROUND(AVG(f.discount) * 100, 2) AS avg_discount_pct,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct,
    ROUND(
        SUM(f.sales),
        2
    ) AS total_sales
FROM fact_orders f
JOIN dim_locations l
    ON f.location_id = l.location_id
GROUP BY l.region
ORDER BY l.region;
-- ============================================================
-- STEP 35B — INVEST MORE LIST
-- Low discount = below overall average discount
-- High margin = above overall average margin
-- Rising sales = latest month > previous month
-- ============================================================

WITH monthly_region_sales AS (
    SELECT
        l.region,
        DATE_TRUNC('month', f.date) AS month,
        SUM(f.sales) AS monthly_sales
    FROM fact_orders f
    JOIN dim_locations l
        ON f.location_id = l.location_id
    GROUP BY
        l.region,
        DATE_TRUNC('month', f.date)
),

region_trend AS (
    SELECT
        region,
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (
            PARTITION BY region
            ORDER BY month
        ) AS previous_month_sales
    FROM monthly_region_sales
),

latest_region_trend AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY month DESC
        ) AS rn
    FROM region_trend
),

region_metrics AS (
    SELECT
        l.region,
        AVG(f.discount) * 100 AS avg_discount_pct,
        SUM(f.sales) AS total_sales,
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100 AS margin_pct
    FROM fact_orders f
    JOIN dim_locations l
        ON f.location_id = l.location_id
    GROUP BY l.region
),

overall_metrics AS (
    SELECT
        AVG(discount) * 100 AS overall_discount_pct,
        SUM(profit) / NULLIF(SUM(sales), 0) * 100 AS overall_margin_pct
    FROM fact_orders
)

SELECT
    rm.region,
    ROUND(rm.avg_discount_pct, 2) AS avg_discount_pct,
    ROUND(rm.margin_pct, 2) AS margin_pct,
    ROUND(om.overall_discount_pct, 2) AS overall_discount_pct,
    ROUND(om.overall_margin_pct, 2) AS overall_margin_pct,
    ROUND(rm.total_sales, 2) AS total_sales,
    ROUND(lrt.monthly_sales, 2) AS latest_month_sales,
    ROUND(lrt.previous_month_sales, 2) AS previous_month_sales
FROM region_metrics rm
CROSS JOIN overall_metrics om
JOIN latest_region_trend lrt
    ON rm.region = lrt.region
   AND lrt.rn = 1
WHERE rm.avg_discount_pct < om.overall_discount_pct
  AND rm.margin_pct > om.overall_margin_pct
  AND lrt.monthly_sales > lrt.previous_month_sales
ORDER BY rm.margin_pct DESC;
-- ============================================================
-- STEP 36A — REGIONAL MARGIN SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW regional_margin_summary AS
SELECT
    l.region,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct,
    AVG(f.discount) * 100 AS avg_discount_pct
FROM fact_orders f
JOIN dim_locations l
    ON f.location_id = l.location_id
GROUP BY l.region;
SELECT *
FROM regional_margin_summary
ORDER BY margin_pct DESC;
-- ============================================================
-- STEP 36B — CATEGORY MARGIN SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW category_margin_summary AS
SELECT
    p.category,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct,
    ROUND(AVG(f.discount) * 100, 2) AS avg_discount_pct
FROM fact_orders f
JOIN dim_products p
    ON f.product_id = p.product_id
GROUP BY p.category;
SELECT *
FROM category_margin_summary
ORDER BY margin_pct DESC;
-- ============================================================
-- STEP 36C — SUB-CATEGORY MARGIN SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW subcategory_margin_summary AS
SELECT
    p.category,
    p.sub_category,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    ROUND(
        SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100,
        2
    ) AS margin_pct,
    ROUND(AVG(f.discount) * 100, 2) AS avg_discount_pct
FROM fact_orders f
JOIN dim_products p
    ON f.product_id = p.product_id
GROUP BY
    p.category,
    p.sub_category;
	SELECT *
FROM subcategory_margin_summary
ORDER BY margin_pct DESC;
-- ============================================================
-- STEP 36D — MONTHLY SALES & PROFIT SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW monthly_sales_profit_summary AS
SELECT
    DATE_TRUNC('month', date) AS month,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS margin_pct
FROM fact_orders
GROUP BY DATE_TRUNC('month', date);
SELECT *
FROM monthly_sales_profit_summary
ORDER BY month;
SELECT * FROM customer_orders ;
SELECT current_user;