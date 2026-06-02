SELECT *
FROM v_supplier_health
WHERE
      cert_expiry_date <= CURRENT_DATE + INTERVAL '30 days'
   OR orders_90d = 0
   OR (
        rolling_avg_yield IS NOT NULL
        AND latest_yield < (rolling_avg_yield * 0.80)
      );
