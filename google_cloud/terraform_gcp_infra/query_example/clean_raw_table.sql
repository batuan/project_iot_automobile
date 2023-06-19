CREATE OR REPLACE VIEW `data-iot-poei-project.silver_dataset.filtered_speed_temperature_view` AS
SELECT *
FROM `data-iot-poei-project.bronze_dataset.raw_stream_iot_data_table`
WHERE 
gpsSpeed >= 0 AND gpsSpeed < 70
AND Oil_Temperature < 240 AND
Pressure_HighPressure is not null AND
TIMESTAMP(dateHour) >= "2023-06-07 15:13:14";
