import os
os.environ['PYSPARK_SUBMIT_ARGS'] = '--packages org.apache.spark:spark-streaming-kafka-0-10_2.12:3.2.0,org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 pyspark-shell'
from pyspark.sql import SparkSession
from pyspark.streaming import StreamingContext
spark = SparkSession \
        .builder \
        .appName("test") \
        .config("spark.jars", "/home/thaibatuana1k41pbc/project_local/spark/spark-doris-connector-3.1_2.12-1.0.0-SNAPSHOT.jar") \
        .config("spark.sql.debug.maxToStringFields", "100") \
        .getOrCreate()

kafkaSource = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", "localhost:9092") \
  .option("subscribe", "sensor_data") \
  .load()

dorisSparkDF = spark.read.format("doris") \
.option("doris.table.identifier", "mongo_doris.iot_sensor_data1") \
.option("doris.fenodes", "localhost:8030") \
.option("user", "root") \
.option("password", "") \
.load()

dorisSparkDF.collect()

data = [{"gpsSpeed":41.60666084273356,"client_number":77,"dateHour":"2023-06-02 14:18:16.474728"},
        {"gpsSpeed":30.16754615219846,"client_number":31,"dateHour":"2023-06-02 14:18:16.475092"}
        ]
data_list = [[x[key] for key in x.keys()] for x in data]
df = spark.createDataFrame(data_list, list(data[0].keys()))
df.write.format("doris") \
  .option("doris.table.identifier", "mongo_doris.iot_sensor_data1") \
.option("doris.fenodes", "localhost:8030") \
.option("user", "root") \
.option("password", "") \
.option("doris.write.fields","gpsSpeed,client_number,dateHour") \
  .save()

from pyspark.sql.functions import col
data = [{"gpsSpeed":41.60666084273356,"gpsSatCount":77,"dateHour":"2023-06-02 14:18:16.474728","client_id":"cars/7","Pump_Speed":1785,"Pressure_HighPressureReturn":7,"Pressure_HighPressure":33159,"Oil_Temperature":152,"Machine_Speed_Measured":20,"Gear":124,"Brake_pedal":135,"Ast_HPMB1_Pressure_bar":6,"Ast_HPMA_Pressure_bar":11,"Ast_FrontAxleSpeed_Rpm":32925,"Accel_pedal":46,"AST_Direction":20},
{"gpsSpeed":30.16754615219846,"gpsSatCount":31,"dateHour":"2023-06-02 14:18:16.475092","client_id":"cars/8","Pump_Speed":1258,"Pressure_HighPressureReturn":11,"Pressure_HighPressure":33183,"Oil_Temperature":143,"Machine_Speed_Measured":20,"Gear":125,"Brake_pedal":127,"Ast_HPMB1_Pressure_bar":7,"Ast_HPMA_Pressure_bar":3,"Ast_FrontAxleSpeed_Rpm":33135,"Accel_pedal":39,"AST_Direction":20},
{"gpsSpeed":86.68163413814607,"gpsSatCount":254,"dateHour":"2023-06-02 14:18:16.479768","client_id":"cars/4","Pump_Speed":1285,"Pressure_HighPressureReturn":5,"Pressure_HighPressure":33043,"Oil_Temperature":155,"Machine_Speed_Measured":20,"Gear":132,"Brake_pedal":134,"Ast_HPMB1_Pressure_bar":11,"Ast_HPMA_Pressure_bar":8,"Ast_FrontAxleSpeed_Rpm":33063,"Accel_pedal":80,"AST_Direction":20},
{"gpsSpeed":0.48792041056762847,"gpsSatCount":77,"dateHour":"2023-06-02 14:18:16.486976","client_id":"cars/9","Pump_Speed":822,"Pressure_HighPressureReturn":4,"Pressure_HighPressure":32772,"Oil_Temperature":23,"Machine_Speed_Measured":20,"Gear":127,"Brake_pedal":136,"Ast_HPMB1_Pressure_bar":13,"Ast_HPMA_Pressure_bar":8,"Ast_FrontAxleSpeed_Rpm":33003,"Accel_pedal":96,"AST_Direction":20}]

data_list = [[x[key] for key in x.keys()] for x in data]

# # Create a DataFrame from the dictionary
df = spark.createDataFrame(data_list, list(data[0].keys()))
df.show()

field = ",".join(list(data[0].keys()))
field = ",".join(list(data[0].keys()))
df.write.format("doris") \
  .option("doris.table.identifier", "mongo_doris.iot_sensor_data_test") \
.option("doris.fenodes", "localhost:8030") \
.option("user", "root") \
.option("password", "") \
.option("doris.write.fields", field)\
.save()

from kafka import KafkaConsumer
consumer = KafkaConsumer('sensor_data')
for msg in consumer:
    print(msg)