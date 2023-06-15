locals {
  data_lake_bucket = "data_sensor_demo_gcp_eu3"
}

variable "project" {
  description = "Your GCP Project ID"
  default="data-iot-poei-project"
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default = "europe-west3"
  type = string
}

variable "storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}


variable ""{

}

# BigQuery Dataset
variable "BQ_BRONZE_DATASET" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "bq_bronze_dataset"
}

variable "BQ_SILVER_DATASET" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "bq_silver_dataset"
}

variable "BQ_GOLD_DATASET" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "bq_silver_dataset"
}

# BigQuery Table

variable "BRONZE_IOT_RAW_TABLE" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "raw_stream_iot_data_table"
}

variable "BRONZE_CAR_INFORMATION" {
  description = "BigQuery table that raw data (from GCS) will be written to"
  type = string
  default = "car_information"
}

variable "BRONZE_FRANCE_GEO_INFO" {
  description = "BigQuery table that raw data (from GCS) will be written to"
  type = string
  default = "france_geo_info"
}