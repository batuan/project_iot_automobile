# /**
#  * Copyright 2019 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */

# module "instance_template1" {
#   source             = "terraform-google-modules/vm/google//modules/instance_template"
#   version            = "~> 7.8"
#   project_id         = var.project
#   region             = var.region
#   machine_type       = "e2-small"
#   network            = var.network
#   subnetwork         = var.subnetwork
#   service_account    = var.service_account
#   disk_size_gb       = 10
#   disk_type          = "pd-standard"
#   source_image_project = "ubuntu-os-cloud"
#   source_image_family = "ubuntu-2004-lts"
#   # source_image       = "ubuntu-os-cloud/ubuntu-2004-lts"
  
#   startup_script     = file("${path.module}/emqx_start_script.sh.tpl")
#   tags               = ["allow-group1"]
# }


# module "mig1" {
#   source             = "terraform-google-modules/vm/google//modules/mig"
#   version            = "~> 7.8"
#   project_id         = var.project
#   region             = var.region

#   target_size        = 2
#   instance_template  = module.instance_template1.self_link
#   hostname           = "mig1"
  
#   named_ports        = local.named_ports
# }

