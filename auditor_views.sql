CREATE OR REPLACE VIEW v_supplier_health AS
WITH latest_harvest AS (
    SELECT
        h.supplier_id,
        h.harvest_date,
        h.yield_kg,
        ROW_NUMBER() OVER (
            PARTITION BY h.supplier_id
            ORDER BY h.harvest_date DESC
        ) AS rn,
        AVG(h.yield_kg) OVER (
            PARTITION BY h.supplier_id
            ORDER BY h.harvest_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_yield
    FROM Harvests h
),
order_counts AS (
    SELECT
        supplier_id,
        COUNT(*) AS orders_90d
    FROM Orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY supplier_id
)
SELECT
    s.supplier_id,
    s.supplier_name,
    s.status,
    s.cert_expiry_date,

    CASE
        WHEN s.cert_expiry_date IS NULL THEN 'Unknown'
        WHEN s.cert_expiry_date < CURRENT_DATE THEN 'Expired'
        WHEN s.cert_expiry_date <= CURRENT_DATE + INTERVAL '30 days'
            THEN 'Expiring Soon'
        ELSE 'Valid'
    END AS cert_status,

    COALESCE(o.orders_90d, 0) AS orders_90d,

    lh.yield_kg AS latest_yield,
    lh.rolling_avg_yield

FROM Suppliers s
LEFT JOIN order_counts o
    ON s.supplier_id = o.supplier_id
LEFT JOIN latest_harvest lh
    ON s.supplier_id = lh.supplier_id
    AND lh.rn = 1;
