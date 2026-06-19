-- sql/staging/02_create_staging.sql
-- Silver layer: cleaned, typed, validated, deduplicated

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.fire_detections_clean (
    id                    BIGSERIAL PRIMARY KEY,

    latitude              FLOAT NOT NULL,
    longitude             FLOAT NOT NULL,
    lat_grid              FLOAT,
    lon_grid              FLOAT,

    brightness_unified    FLOAT,
    bright_t31            FLOAT,
    bright_ti4            FLOAT,
    bright_ti5            FLOAT,
    brightness_delta      FLOAT,
    frp                   FLOAT NOT NULL,

    scan                  FLOAT,
    track                 FLOAT,
    pixel_area_km2        FLOAT,

    acq_datetime          TIMESTAMPTZ,
    acq_date              DATE,
    daynight              CHAR(1),

    satellite             TEXT,
    instrument            TEXT,
    confidence_score      INTEGER,
    source                TEXT,

    silver_processed_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stg_acq_datetime ON staging.fire_detections_clean(acq_datetime);
CREATE INDEX IF NOT EXISTS idx_stg_latlon        ON staging.fire_detections_clean(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_stg_frp           ON staging.fire_detections_clean(frp);
CREATE INDEX IF NOT EXISTS idx_stg_instrument    ON staging.fire_detections_clean(instrument);
