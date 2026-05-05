CREATE OR REPLACE TRIGGER trg_oracle_alert
AFTER INSERT ON fin_market_telemetry
FOR EACH ROW
WHEN (NEW.instrument_ticker = 'ORCL' AND NEW.price_value > 300.00)
BEGIN
    DBMS_OUTPUT.PUT_LINE('CRITICAL MARKET INFLECTION: Oracle target reached. ' ||
                         'Current Price: ' || :NEW.price_value);
END;
/
