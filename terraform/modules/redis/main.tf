resource "random_password" "password" {
    length  = 32
    special = false
}

data "google_compute_subnetwork" "subnet" {
    name = "fleet-compute-subnet"
    region = var.region
}

resource "google_compute_instance" "instance" {
    name = "fleet-redis-instance"
    machine_type = "e2-micro"

    tags = ["redis"]

    boot_disk {
        initialize_params {
            image = "cos-cloud/cos-121-lts"
        }
    }
    
    network_interface {
        subnetwork = data.google_compute_subnetwork.subnet.id
    }

    metadata = {
        gce-container-declaration = templatefile("${path.module}/redis.yaml", {
            version = var.redis_version
            password = random_password.password.result
        })
    }
}