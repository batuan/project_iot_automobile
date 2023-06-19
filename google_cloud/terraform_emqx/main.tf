provider "google" {
#   credentials = "/Users/batuan/Documents/apply_viec_2023/jems/DataScientest/data-iot-poei-project-321b743606a5.json"
  project     = "data-iot-poei-project"
  region      = "europe-west3"
}

resource "google_compute_network" "emqx_network" {
  name = var.network
}

resource "google_compute_subnetwork" "emqx_subnetwork" {
  name          = var.subnetwork
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.emqx_network.self_link
}

resource "google_compute_firewall" "emqx_firewall" {
  name    = "emqx-firewall"
  network = google_compute_network.emqx_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["1883", "8883", "8083", "8084", "22", "80", "443", "18083"]  # Adjust the ports according to your EMQX configuration
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "emqx_ping" {
  name    = "emqx-ping"
  network = google_compute_network.emqx_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]  # Adjust the ports according to your EMQ X configuration
  }
  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "sctp"
  }

  source_ranges = [
    "10.0.0.0/24",
  ]
}

resource "google_compute_instance_template" "emqx" {
  name = "emqx-template"
  description = "install emqx when start"
  machine_type = "e2-small"
  region = "europe-west3"
  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2004-lts"
    type         = "pd-standard"
    disk_size_gb = 10
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get upgrade -y
    wget https://www.emqx.com/en/downloads/enterprise/5.0.3/emqx-enterprise-5.0.3-ubuntu20.04-amd64.tar.gz -P ~/
    mkdir -p ~/emqx && tar -zxvf ~/emqx-enterprise-5.0.3-ubuntu20.04-amd64.tar.gz -C ~/emqx
    ~/emqx/bin/emqx start
  EOF

  network_interface {
    network       = google_compute_network.emqx_network.self_link
    subnetwork    = google_compute_subnetwork.emqx_subnetwork.self_link
    access_config {
      // Leave this empty to assign an ephemeral IP address to each instance
    }
  }
}

resource "google_compute_instance_group_manager" "emqx_cluster" {
  name        = "emqx-cluster"
  description = "EMQ X Cluster Instance Group"
  zone = "europe-west3-a"

  base_instance_name = "emqx-instance"
  target_size        = 1

  version {
    name              = "app-emqx"
    instance_template = google_compute_instance_template.emqx.self_link
  }

  named_port {
    name = "mqtt-ui"
    port = 18083
  }
  named_port {
    name = "mqtt"
    port = 1883
  }
  named_port {
    name = "mqtts"
    port = 8883
  }

  named_port {
    name = "http"
    port = 80
  }
}

# output "external_ips" {
#   value = google_compute_instance.emqx_ee[*].network_interface.0.access_config.0.nat_ip
# }

# output "instance_ips" {
#   value = google_compute_instance.emqx_ee[*].network_interface[0].network_ip
# }

output "emqx_cluster" {
  value = google_compute_instance_group_manager.emqx_cluster.instance_group
}

output "emqx_cluster_ips" {
  value = google_compute_instance_group_manager.emqx_cluster.id
}