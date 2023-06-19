CREATE OR REPLACE VIEW `data-iot-poei-project.silver_dataset.view_data_depart_commune` AS
SELECT A.*, B.Departement_alpha, B.Commune
FROM `data-iot-poei-project.bronze_dataset.raw_stream_iot_data_table` AS A
JOIN `data-iot-poei-project.bronze_dataset.france_geo_info` AS B
ON A.lat >= B.Latitude_la_plus_au_sud AND A.lat <= B.Latitude_la_plus_au_nord
   AND A.long >= B.Longitude_la_plus____l___ouest AND A.long <= B.Longitude_la_plus____l___est;