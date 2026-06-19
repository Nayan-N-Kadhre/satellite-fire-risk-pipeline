"""
scripts/test_spark_connection.py
Verifies the local PySpark driver can connect to and run a job on
the Dockerized Spark cluster. Run this after `docker compose up -d`
to confirm the cluster is reachable before running pipeline scripts.
"""

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))
from config.settings import SPARK_MASTER, SPARK_CONNECTION_CONFIG

from pyspark.sql import SparkSession

builder = (
    SparkSession.builder
    .appName("ConnectivityTest")
    .master(SPARK_MASTER)
)
for key, value in SPARK_CONNECTION_CONFIG.items():
    builder = builder.config(key, value)

spark = builder.getOrCreate()

print("Spark version:", spark.version)
df = spark.range(1000).toDF("number")
print("Row count:", df.count())
print("CONNECTION TEST PASSED")

spark.stop()
