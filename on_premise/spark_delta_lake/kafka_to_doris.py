import os
os.environ['PYSPARK_SUBMIT_ARGS'] = '--packages org.apache.spark:spark-streaming-kafka-0-10_2.12:3.2.0,org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 pyspark-shell'

from pyspark.sql import SparkSession
from pyspark.streaming import StreamingContext
from pyspark.sql.functions import from_json
from pyspark.sql.types import StructType, StructField, StringType


spark = SparkSession \
        .builder \
        .appName("test") \
        .config("spark.sql.debug.maxToStringFields", "100") \
        .config("spark.jars", "/home/thaibatuana1k41pbc/project_local/spark/spark-doris-connector-3.1_2.12-1.0.0-SNAPSHOT.jar") \
        .getOrCreate()

df = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", "localhost:9092") \
  .option("subscribe", "cars_senso_doris") \
  .option("startingOffsets", "latest") \
  .load()

def process_batch(df, batch_id):
    # Collect the rows of the DataFrame as a list
    rows = df.collect()
    # Process each row in the batch
    for row in rows:
        # Perform required processing on the row
        print(row['value'])

query = df.selectExpr("CAST(value AS STRING)").writeStream.foreachBatch(process_batch).start()
query.awaitTermination()