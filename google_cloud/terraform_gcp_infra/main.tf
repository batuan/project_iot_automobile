terraform {
  required_version = ">= 1.0"
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
#   credentials = "./data-iot-poei-project-321b743606a5.json"
  project     = var.project
  region      = var.region
}

resource "google_pubsub_topic" "cars_sensor_topic" {
  name = "my-cars-sensor-topic"
}

resource "google_pubsub_subscription" "subscription1" {
  name   = "my-cars-sensor-subscription"
  topic  = google_pubsub_topic.cars_sensor_topic.name
  ack_deadline_seconds = 10
}


resource "google_bigquery_dataset" "bronze_dataset" {
  dataset_id = var.BQ_BRONZE_DATASET
  location   = var.region
}
 

resource "google_bigquery_table" "cars_sensor_table" {
  dataset_id = google_bigquery_dataset.bronze_dataset.dataset_id
  table_id   = var.BRONZE_IOT_RAW_TABLE
  deletion_protection = false
  
  time_partitioning {
    type = "HOUR"
    field = "dateHour"
  }
 
  schema = file("./table_schema/raw_iot.json")
}

resource "google_bigquery_table" "france_geo_info" {
  dataset_id = google_bigquery_dataset.bronze_dataset.dataset_id
  table_id   = var.BRONZE_FRANCE_GEO_INFO
  deletion_protection = false

  # schema = file("./table_schema/france_geo_info.json")

  provisioner "local-exec" {
    command = "bq load --source_format=PARQUET ${google_bigquery_table.france_geo_info.dataset_id}.${google_bigquery_table.france_geo_info.table_id} ./table_resource/france_departement_info.parquet"
  }
}

resource "google_bigquery_table" "car_information" {
  dataset_id = google_bigquery_dataset.bronze_dataset.dataset_id
  table_id   = var.BRONZE_CAR_INFORMATION
  deletion_protection = false
  
  # schema = file("./table_schema/car_information.json")
  provisioner "local-exec" {
    command = "bq load --source_format=PARQUET ${google_bigquery_table.car_information.dataset_id}.${google_bigquery_table.car_information.table_id} ./table_resource/car_information.parquet"
  }
}


# Bucket
resource "google_storage_bucket" "bucket1" {
    name          = "sensor-cars-test-bucket1"
    location      = "europe-west3"
    force_destroy = true
}
resource "google_storage_bucket_object" "tmp_directory" {
  name       = "tmp/"
  bucket     = google_storage_bucket.bucket1.name
  content = " "
}

# resource "google_dataflow_job" "pubsub_stream" {
#     name = "realtime-sensors-dataflow-job1"
#     template_gcs_path = "gs://dataflow-templates/2022-01-24-00_RC00/PubSub_Subscription_to_BigQuery"
#     temp_gcs_location = google_storage_bucket_object.tmp_directory.name
#     enable_streaming_engine = true

#     parameters = {
#       inputSubscription = google_pubsub_subscription.subscription1.id
#       outputTableSpec    = google_bigquery_table.cars_sensor_table.table_id
#     }
#     on_delete = "drain"
# }

module "dataflow" {
  source  = "terraform-google-modules/dataflow/google"
  version = "2.2.0"

  project_id  = var.project
  name = var.DATAFLOW_JOB_NAME #+ "_${timestamp()}"
  on_delete = "drain"
  region = "europe-west3"
  zone = "europe-west3-a"
  max_workers = 1
  template_gcs_path =  "gs://dataflow-templates-europe-west3/latest/PubSub_Subscription_to_BigQuery"
  temp_gcs_location = google_storage_bucket_object.tmp_directory.name
  parameters = {
        inputSubscription = "projects/data-iot-poei-project/subscriptions/my-cars-sensor-subscription"
        outputTableSpec    = "data-iot-poei-project:cars_sensor_dataset.cars-sensor-real-time-data"
  }
}