CREATE OR REPLACE PROCEDURE prc_check_stale_telemetry IS
BEGIN
    FOR rec IN (
        SELECT instrument_ticker, MAX(telemetry_ts) as last_update
        FROM fin_market_telemetry
        GROUP BY instrument_ticker
        HAVING MAX(telemetry_ts) < CURRENT_TIMESTAMP - INTERVAL '1' DAY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ALERT: Data stale for ' || rec.instrument_ticker || 
                             '. Last update: ' || rec.last_update);
    END LOOP;
END;
/
