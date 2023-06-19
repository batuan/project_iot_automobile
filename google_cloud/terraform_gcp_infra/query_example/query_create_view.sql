CREATE VIEW `data-iot-poei-project.dataplex_test_dataset_eu3.test_view_data_topic`
AS
SELECT dateHour, gpsSpeed FROM `data-iot-poei-project.test_project.data_topic_client` WHERE DATE(dateHour) >= "2023-06-01" LIMIT 1000