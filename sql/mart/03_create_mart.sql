-- sql/mart/03_create_mart.sql
-- Gold layer: ML-ready features and model predictions for dashboarding

CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS mart.fire_features (
    id                    BIGSERIAL PRIMARY KEY,

    latitude              FLOAT,
    longitude             FLOAT,
    grid_id               TEXT,
    acq_datetime          TIMESTAMPTZ,
    source                TEXT,

    hour_of_day           INTEGER,
    day_of_week           INTEGER,
    month_of_year         INTEGER,
    season                TEXT,
    is_daytime            INTEGER,

    lat_grid              FLOAT,
    lon_grid              FLOAT,
    latitude_band         TEXT,
    hemisphere            CHAR(1),
    pixel_area_km2        FLOAT,
    frp_per_km2           FLOAT,

    brightness_unified    FLOAT,
    brightness_delta      FLOAT,
    confidence_score      INTEGER,
    instrument            TEXT,
    satellite              TEXT,

    fire_count_7d         FLOAT,
    fire_count_30d        FLOAT,
    fire_count_90d        FLOAT,
    fire_count_365d       FLOAT,
    avg_frp_7d            FLOAT,
    avg_frp_30d           FLOAT,
    avg_frp_90d           FLOAT,
    avg_frp_365d          FLOAT,

    frp                   FLOAT,
    frp_log               FLOAT,
    risk_tier             TEXT,
    risk_tier_label       INTEGER
);

CREATE INDEX IF NOT EXISTS idx_mart_datetime   ON mart.fire_features(acq_datetime);
CREATE INDEX IF NOT EXISTS idx_mart_grid_id    ON mart.fire_features(grid_id);
CREATE INDEX IF NOT EXISTS idx_mart_risk_tier  ON mart.fire_features(risk_tier);

CREATE TABLE IF NOT EXISTS mart.fire_predictions (
    id                          BIGSERIAL PRIMARY KEY,
    latitude                    FLOAT,
    longitude                   FLOAT,
    acq_datetime                TIMESTAMPTZ,
    frp                         FLOAT,
    risk_tier                   TEXT,
    risk_tier_label             INTEGER,
    predicted_risk_tier_label   FLOAT,
    predicted_at                TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pred_datetime ON mart.fire_predictions(acq_datetime);
CREATE INDEX IF NOT EXISTS idx_pred_latlon   ON mart.fire_predictions(latitude, longitude);

CREATE OR REPLACE VIEW mart.vw_daily_risk_summary AS
SELECT
    DATE_TRUNC('day', acq_datetime)   AS detection_date,
    grid_id,
    latitude_band,
    hemisphere,
    COUNT(*)                           AS total_detections,
    AVG(frp)                           AS avg_frp,
    MAX(frp)                           AS max_frp,
    SUM(CASE WHEN risk_tier = 'Extreme' THEN 1 ELSE 0 END) AS extreme_count,
    SUM(CASE WHEN risk_tier = 'High'    THEN 1 ELSE 0 END) AS high_count,
    SUM(CASE WHEN risk_tier = 'Medium'  THEN 1 ELSE 0 END) AS medium_count,
    SUM(CASE WHEN risk_tier = 'Low'     THEN 1 ELSE 0 END) AS low_count
FROM mart.fire_features
GROUP BY 1, 2, 3, 4;

CREATE OR REPLACE VIEW mart.vw_prediction_accuracy AS
SELECT
    risk_tier                       AS actual_tier,
    CASE predicted_risk_tier_label::INTEGER
        WHEN 0 THEN 'Low'
        WHEN 1 THEN 'Medium'
        WHEN 2 THEN 'High'
        WHEN 3 THEN 'Extreme'
    END                             AS predicted_tier,
    COUNT(*)                        AS count
FROM mart.fire_predictions
GROUP BY 1, 2
ORDER BY 1, 2;
