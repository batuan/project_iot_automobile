CREATE OR REPLACE VIEW `data-iot-poei-project.gold_dataset.view_agg_data` AS
SELECT TIMESTAMP_TRUNC(dateHour, HOUR) AS aggregated_timestamp,clientid,
       AVG(gpsSpeed) AS average_gpsSpeed,
       AVG(gpsSatCount) AS average_gpsSatCount,
       AVG(Gear) AS average_Gear,
       AVG(Brake_pedal) AS average_Brake_pedal,
       AVG(Pump_Speed) AS average_Pump_Speed,
       AVG(Oil_Temperature) AS average_Oil_Temperature,
       ANY_VALUE(Departement_alpha) as any_Departement_alpha, ANY_VALUE(Commune) as any_Commune
 
FROM `data-iot-poei-project.silver_dataset.view_data_depart_commune`
GROUP BY clientid, aggregated_timestamp
ORDER BY aggregated_timestamp, clientid;
