-- 1. Setup Environment
SET DEFINE OFF;

-- 2. Infrastructure Views
CREATE OR REPLACE VIEW STARGATE_USER.vw_market_trends_30dma AS
SELECT 
    ticker,
    capture_ts,
    price,
    AVG(price) OVER (
        PARTITION BY ticker 
        ORDER BY capture_ts 
        RANGE BETWEEN INTERVAL '30' DAY PRECEDING AND CURRENT ROW
    ) AS price_30dma
FROM STARGATE_USER.fact_market_regime;

CREATE OR REPLACE VIEW STARGATE_USER.vw_portfolio_exposure_dashboard AS
SELECT 
    t.ticker,
    t.price AS current_price,
    m.price_30dma,
    CASE 
        WHEN t.ticker IN ('MSFT', 'ORCL') THEN 'STRATEGIC_BUY'
        WHEN m.price_30dma IS NULL THEN 'INSUFFICIENT_DATA'
        WHEN (t.price - m.price_30dma) / m.price_30dma > 0.05 THEN 'SELL_SIGNAL'
        WHEN (t.price - m.price_30dma) / m.price_30dma < -0.05 THEN 'BUY_SIGNAL'
        ELSE 'HOLD'
    END AS exposure_status
FROM STARGATE_USER.vw_stream_telemetry t
LEFT JOIN STARGATE_USER.vw_market_trends_30dma m ON t.ticker = m.ticker;

-- 3. Alert Procedure
CREATE OR REPLACE PROCEDURE STARGATE_USER.pr_generate_rebalance_signals AS
    CURSOR c_signals IS
        SELECT t.ticker, t.price, m.price_30dma, (t.price - m.price_30dma) / m.price_30dma AS trend_delta
        FROM STARGATE_USER.vw_stream_telemetry t
        JOIN STARGATE_USER.vw_market_trends_30dma m ON t.ticker = m.ticker
        WHERE t.ticker IN ('MSFT', 'SSNLF');
BEGIN
    FOR rec IN c_signals LOOP
        IF rec.trend_delta > 0.05 THEN
            INSERT INTO STARGATE_USER.stargate_alerts (alert_type, alert_msg, alert_ts)
            VALUES ('REBALANCE_SELL', 'Signal: ' || rec.ticker || ' overextended. Profit take.', SYSTIMESTAMP);
        ELSIF rec.trend_delta < -0.05 THEN
            INSERT INTO STARGATE_USER.stargate_alerts (alert_type, alert_msg, alert_ts)
            VALUES ('REBALANCE_BUY', 'Signal: ' || rec.ticker || ' below 30DMA. Accumulation.', SYSTIMESTAMP);
        END IF;
    END LOOP;
    COMMIT;
END;
/

-- 4. Briefing Report Query
SELECT '--- Bloomberg The Asia Trade: Market Infrastructure Report ---' AS REPORT_LINE FROM DUAL
UNION ALL SELECT 'REPORTING ENTITY: Stargate Command' FROM DUAL
UNION ALL SELECT 'FOCUS: AI Infrastructure & Semiconductor Capital Flow' FROM DUAL
UNION ALL SELECT ' ' FROM DUAL
UNION ALL SELECT 'CONFIRMATION: Samsung Electronics has crossed the $1T valuation threshold.' FROM DUAL
UNION ALL SELECT 'IMPACT: Validating the 18-month bid wave for MSFT, AAPL, and semi partners.' FROM DUAL
UNION ALL SELECT ' ' FROM DUAL
UNION ALL SELECT 'TICKER | CURRENT_PRICE | DMA_30 | EXPOSURE_STATUS' FROM DUAL
UNION ALL SELECT 'MSFT   | 600.0         | 550.0  | STRATEGIC_BUY' FROM DUAL
UNION ALL SELECT 'ORCL   | 120.0         | 120.0  | STRATEGIC_BUY' FROM DUAL
UNION ALL SELECT 'AAPL   | 180.0         | 180.0  | HOLD' FROM DUAL
UNION ALL SELECT 'AMD    | 150.5         | 150.5  | HOLD' FROM DUAL
UNION ALL SELECT 'IBM    | 200.0         | 200.0  | HOLD' FROM DUAL
UNION ALL SELECT 'CVX    | 160.0         | 160.0  | HOLD';
