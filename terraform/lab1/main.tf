terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
        }
    }
}

provider "google" {
    project = var.project_id
    region  = var.region
    zone    = var.zone
}

resource "google_compute_instance" "vm" {
    name         = "lab1-instance"
    machine_type = "e2-micro"

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
        }
    }

    network_interface {
        network = "default"
        access_config { }
    }

    metadata_startup_script = templatefile("${path.module}/startup.sh", {
        server_url = var.server_url
    })
}