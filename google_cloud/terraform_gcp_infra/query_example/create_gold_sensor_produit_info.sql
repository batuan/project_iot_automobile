CREATE OR REPLACE VIEW `data-iot-poei-project.gold_dataset.sensor_data_client_product_info_view`
AS
SELECT
  s.*,
  c.Year,
  c.Trim__description_,
  c.Colors_exterior,
  c.Doors,
  c.Gross_weight__lbs_,
  c.Engine_size__l_,
  c.Horsepower__HP_,
  c.Valves
FROM
  `data-iot-poei-project.silver_dataset.view_data_depart_commune` AS s
JOIN
  `data-iot-poei-project.bronze_dataset.car_information` AS c
ON
  s.clientid = c.Model;