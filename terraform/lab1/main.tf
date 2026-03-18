provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
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
        subnetwork = module.server.subnet
    }

    metadata_startup_script = templatefile("${path.module}/startup.sh", {
        server_hostname = "${var.server_ip}:8080"
        enroll_secret = var.enroll_secret
    })
}