variable "project" {
  description = "Your GCP Project ID"
  default     = "data-iot-poei-project"
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default = "europe-west3"
  type = string
}


variable "network" {
  description = "Name of the network to create resources in."
  type        = string
  default = "emqx-network"
}

variable "subnetwork" {
  description = "Name of the subnetwork to create resources in."
  type        = string
  default = "emqx-subnetwork"
}

variable "service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account"
  type = object({
    email  = string
    scopes = set(string)
  })
  default = {
    email = "data-iot-poei-project@appspot.gserviceaccount.com",
    scopes = [ "cloud-platform" ]
  }
}

# variable "subnetwork_project" {
#   description = "Name of the project for the subnetwork. Useful for shared VPC."
#   type        = string
# }