Create or replace external table `data-iot-poei-project.dataplex_test_dataset_eu3.test_images_table`
with connection `projects/data-iot-poei-project/locations/europe-west3/connections/test_biglake_dataplex_eu3`
options (object_metadata="SIMPLE", uris=["gs://data_sensor_demo_eu3/*.jpeg"]);

select data, *
from `dataplex_test_dataset_eu3.test_images_table`
where updated > timestamp("2023-06-05 13:07:19.071000 UTC")
limit 1000;
