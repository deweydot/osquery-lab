provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

provider "google-beta" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

module "server" {
    source = "../modules/server"
}

resource "google_compute_instance" "node1" {
    name = "lab1-instance"
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
        server_hostname = trimprefix(module.server.server_url, "https://")
        enroll_secret = module.server.enroll_secret
    })
}