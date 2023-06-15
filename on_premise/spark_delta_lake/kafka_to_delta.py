import os
os.environ['PYSPARK_SUBMIT_ARGS'] = '--packages org.apache.spark:spark-streaming-kafka-0-10_2.12:3.2.0,org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0,io.delta:delta-core_2.12:2.4.0 pyspark-shell'

from pyspark.sql import SparkSession
from pyspark.streaming import StreamingContext
from pyspark.sql.functions import from_json
from pyspark.sql.types import StructType, StructField, StringType
from pyspark.sql.types import StructType, StructField, TimestampType, FloatType, IntegerType, StringType, DateType
import json
from datetime import datetime


spark = SparkSession \
        .builder \
        .appName("test") \
        .config("spark.sql.debug.maxToStringFields", "100") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")\
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .getOrCreate()

df_kafka = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", "localhost:9092") \
  .option("subscribe", "cars_sensor_data_delta") \
  .option("startingOffsets", "latest") \
  .load()

schema = StructType([
    StructField("dateHour", TimestampType(), True),
    StructField("gpsSpeed", FloatType(), True),
    StructField("gpsSatCount", IntegerType(), True),
    StructField("Gear", IntegerType(), True),
    StructField("Brake_pedal", IntegerType(), True),
    StructField("Accel_pedal", IntegerType(), True),
    StructField("Machine_Speed_Measured", IntegerType(), True),
    StructField("AST_Direction", IntegerType(), True),
    StructField("Ast_HPMB1_Pressure_bar", IntegerType(), True),
    StructField("Ast_HPMA_Pressure_bar", IntegerType(), True),
    StructField("Pressure_HighPressureReturn", IntegerType(), True),
    StructField("Pressure_HighPressure", IntegerType(), True),
    StructField("Oil_Temperature", IntegerType(), True),
    StructField("Ast_FrontAxleSpeed_Rpm", IntegerType(), True),
    StructField("Pump_Speed", IntegerType(), True),
    StructField("client_id", StringType(), True)
])

header = ['dateHour', 'gpsSpeed', 'gpsSatCount', 'Gear', 'Brake_pedal', 'Accel_pedal', 'Machine_Speed_Measured', 'AST_Direction', 'Ast_HPMB1_Pressure_bar', 'Ast_HPMA_Pressure_bar', 'Pressure_HighPressureReturn', 'Pressure_HighPressure', 'Oil_Temperature', 'Ast_FrontAxleSpeed_Rpm', 'Pump_Speed', 'client_id']


def process_batch(df, batch_id):
    # Collect the rows of the DataFrame as a list
    rows = df.collect()
    # print(rows)
    if len(rows) == 0:
        print(rows)
    else:
        # for x in rows:
        #     print(x['value'])
        data_json = []
        for x in rows:
            x = json.loads(x['value'])
            x['dateHour'] = datetime.strptime(x['dateHour'], '%Y-%m-%d %H:%M:%S.%f')
            x['Machine_Speed_Measured'] = x.pop('Machine_Speed_Mesured')
            x['client_id'] = x.pop('clientid')
            data_json.append(x)
        data_list = [[x[key] for key in header] for x in data_json]
        df_rows = spark.createDataFrame(data_list, schema)
        # df_rows.show()

        df_rows.write \
        .format("delta") \
        .mode("overwrite") \
        .option("partitionOverwriteMode", "dynamic") \
        .save("/home/thaibatuana1k41pbc/project_local/spark/spark-warehouse/iot_sensor_data_test1")


query = df_kafka.selectExpr("CAST(value AS STRING)").select("value").writeStream.foreachBatch(process_batch).start()

# query = df.selectExpr("CAST(value AS STRING)").writeStream.foreachBatch(process_batch).start()
query.awaitTermination()