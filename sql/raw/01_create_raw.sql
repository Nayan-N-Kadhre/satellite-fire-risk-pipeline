-- sql/raw/01_create_raw.sql
-- Bronze layer: exactly as ingested, no transformations

CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.fire_detections (
    id               BIGSERIAL PRIMARY KEY,
    kafka_key        TEXT,
    kafka_offset     BIGINT,
    kafka_timestamp  TIMESTAMPTZ,

    latitude         FLOAT,
    longitude        FLOAT,

    brightness       FLOAT,
    bright_t31       FLOAT,
    bright_ti4       FLOAT,
    bright_ti5       FLOAT,
    frp              FLOAT,

    scan             FLOAT,
    track            FLOAT,

    acq_date         TEXT,
    acq_time         TEXT,

    satellite        TEXT,
    instrument       TEXT,
    confidence       TEXT,
    version          TEXT,
    daynight         TEXT,
    source           TEXT,
    ingested_at      TEXT,
    replay_offset    TEXT,
    bronze_processed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_raw_acq_date ON raw.fire_detections(acq_date);
CREATE INDEX IF NOT EXISTS idx_raw_source   ON raw.fire_detections(source);
CREATE INDEX IF NOT EXISTS idx_raw_latlon   ON raw.fire_detections(latitude, longitude);
