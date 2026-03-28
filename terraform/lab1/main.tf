provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

resource "random_password" "admin" {
    length = 32
    special = false
}

resource "random_password" "enroll" {
    length = 32
    special = false
}

module "server" {
    source = "../server"
    admin_password = random_password.admin.result
    enroll_secret = random_password.enroll.result
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
        server_hostname = "${module.server.internal_ip}:8080"
        enroll_secret = random_password.enroll.result
    })
}