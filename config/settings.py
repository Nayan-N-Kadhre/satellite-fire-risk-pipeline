"""
config/settings.py
Central configuration for the satellite-fire-risk-pipeline project.
"""

import socket


def get_local_ip() -> str:
    """
    Dynamically detect this machine's IP address on the network Docker
    containers can route back to (needed for Spark driver.host/bindAddress
    in WSL2, since the IP changes across reboots).

    Connects a UDP socket to a public address (no actual packets sent for
    UDP connect — this just asks the OS routing table which local interface
    it would use) to determine the outbound-facing IP.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"  # fallback, won't work for Spark but avoids a crash
    finally:
        s.close()
    return ip


# ─── NASA FIRMS API ──────────────────────────────────────────────────────────
# Get your free MAP_KEY at: https://firms.modaps.eosdis.nasa.gov/api/map_key/
# Register for NASA Earthdata Login at: https://urs.earthdata.nasa.gov/
FIRMS_MAP_KEY = "YOUR_MAP_KEY_HERE"
FIRMS_BASE_URL = "https://firms.modaps.eosdis.nasa.gov/api"
FIRMS_SOURCES = ["MODIS_NRT", "VIIRS_SNPP_NRT", "VIIRS_NOAA20_NRT"]
FIRMS_ARCHIVE_PATH = "./data/archive/"

# ─── Kafka (Dockerized) ──────────────────────────────────────────────────────
KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
KAFKA_TOPIC_RAW = "firms.detections.raw"
KAFKA_TOPIC_PROCESSED = "firms.detections.processed"
KAFKA_TOPIC_ALERTS = "firms.alerts.high_risk"
KAFKA_PRODUCER_BATCH_SIZE = 1000
KAFKA_PRODUCER_SLEEP_SEC = 0.5
KAFKA_CONSUMER_GROUP = "spark-processor"

# ─── PostgreSQL (Dockerized) ─────────────────────────────────────────────────
POSTGRES_HOST = "localhost"
POSTGRES_PORT = 5432
POSTGRES_DB = "firms_db"
POSTGRES_USER = "wildfire"
POSTGRES_PASSWORD = "wildfire123"
POSTGRES_JDBC_URL = f"jdbc:postgresql://{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

SCHEMA_RAW = "raw"
SCHEMA_STAGING = "staging"
SCHEMA_MART = "mart"

# ─── Apache Spark (Dockerized cluster) ───────────────────────────────────────
SPARK_MASTER = "spark://localhost:7077"
SPARK_APP_NAME = "satellite-fire-risk-pipeline"
SPARK_EXECUTOR_MEMORY = "2g"
SPARK_DRIVER_MEMORY = "1g"

# WSL2-specific: the Docker containers need to reach back to this machine's
# driver process. This IP changes across WSL2 reboots, so detect it dynamically
# rather than hardcoding (confirmed necessary during local connectivity testing).
SPARK_DRIVER_HOST = get_local_ip()

# Standard config dict to pass into SparkSession.builder for every script
SPARK_CONNECTION_CONFIG = {
    "spark.driver.host": SPARK_DRIVER_HOST,
    "spark.driver.bindAddress": SPARK_DRIVER_HOST,
}

PARQUET_RAW_PATH = "./data/parquet/raw/"
PARQUET_FEATURES_PATH = "./data/parquet/features/"
PARQUET_PREDICTIONS_PATH = "./data/parquet/predictions/"

# ─── ML Configuration ────────────────────────────────────────────────────────
TARGET_REGRESSION = "frp"
TARGET_CLASSIFICATION = "risk_tier"

RISK_THRESHOLDS = {
    "Low": (0, 50),
    "Medium": (50, 200),
    "High": (200, 1000),
    "Extreme": (1000, float("inf"))
}

TEST_SIZE = 0.2
RANDOM_SEED = 42
CV_FOLDS = 5
OPTUNA_TRIALS = 50
MODEL_PATH = "./ml/models/saved/"

# ─── Feature Engineering ─────────────────────────────────────────────────────
GRID_RESOLUTION = 0.25
ROLLING_WINDOWS_DAYS = [7, 30, 90, 365]
MIN_CONFIDENCE = 30


if __name__ == "__main__":
    # Quick sanity check when run directly
    print("Detected local IP for Spark driver:", get_local_ip())
