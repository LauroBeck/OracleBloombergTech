-- 1. Infrastructure Tables
CREATE TABLE market_projections (
    ticker VARCHAR2(10) PRIMARY KEY,
    target_18m NUMBER(10, 2)
);

-- 2. Data Seeding
INSERT INTO market_projections VALUES ('ORCL', 334.89);
INSERT INTO market_projections VALUES ('TSLA', 560.69);
INSERT INTO market_projections VALUES ('MSFT', 590.92);
INSERT INTO market_projections VALUES ('IBM', 328.00);
INSERT INTO market_projections VALUES ('CVX', 210.34);
COMMIT;

-- 3. Integrated Regime View
CREATE OR REPLACE VIEW vw_integrated_market_regime AS
SELECT 
    t.instrument_ticker,
    t.price_value,
    p.target_18m,
    t.telemetry_ts,
    CASE 
        WHEN t.instrument_ticker IN ('ORCL', 'TSLA', 'MSFT', 'IBM') THEN 'AI_INFRASTRUCTURE_GROWTH'
        WHEN t.instrument_ticker IN ('CVX', 'BP') THEN 'INFLATIONARY_HEDGE_FLOOR'
        WHEN t.instrument_ticker IN ('JPM', 'BAC', 'MS') THEN 'FINANCIAL_STRESS_INDICATOR'
        ELSE 'MARKET_BREADTH'
    END as regime_classification
FROM fin_market_telemetry t
JOIN market_projections p ON t.instrument_ticker = p.ticker
WHERE t.telemetry_ts = (SELECT MAX(telemetry_ts) FROM fin_market_telemetry);
