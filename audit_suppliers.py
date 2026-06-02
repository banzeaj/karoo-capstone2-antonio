import psycopg2

DB_CONFIG = {
    "host": "localhost",
    "database": "karoo_organics",
    "user": "postgres",
    "password": "your_password"
}

RISK_QUERY = """
SELECT supplier_id
FROM v_supplier_health
WHERE
      cert_expiry_date <= CURRENT_DATE + INTERVAL '30 days'
   OR orders_90d = 0
   OR (
        rolling_avg_yield IS NOT NULL
        AND latest_yield < (rolling_avg_yield * 0.80)
      );
"""

UPDATE_QUERY = """
UPDATE Suppliers
SET status = %s,
    last_audit = CURRENT_DATE
WHERE supplier_id = %s;
"""


def audit_suppliers():
    conn = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        # Find suppliers needing review
        cur.execute(RISK_QUERY)
        suppliers = cur.fetchall()

        supplier_ids = [row[0] for row in suppliers]

        if supplier_ids:
            updates = [('Review', sid) for sid in supplier_ids]

            cur.executemany(UPDATE_QUERY, updates)

        conn.commit()

        print(f"{len(supplier_ids)} suppliers require review")

        cur.close()

    except psycopg2.Error as e:
        print(f"Database error: {e}")

        if conn:
            conn.rollback()

    except Exception as e:
        print(f"Unexpected error: {e}")

        if conn:
            conn.rollback()

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    audit_suppliers()