SET PAGESIZE 0
SET FEEDBACK OFF
SET LINESIZE 200
SET TRIMSPOOL ON
SET HEAD OFF

SELECT 
    RPAD(instrument_ticker, 12) || ' | ' || 
    LPAD(TO_CHAR(price_value, '999,990.99'), 12) || ' | ' || 
    RPAD(regime_classification, 25) || ' | ' || 
    TO_CHAR(telemetry_ts, 'DD-MON HH12:MI AM')
FROM (
    SELECT instrument_ticker, price_value, regime_classification, telemetry_ts,
           ROW_NUMBER() OVER (PARTITION BY instrument_ticker ORDER BY telemetry_ts DESC) as rn
    FROM vw_integrated_market_regime
)
WHERE rn = 1
ORDER BY regime_classification, price_value DESC;
EXIT;
