resource "random_password" "password" {
    length  = 32
    special = false
}

resource "google_compute_firewall" "redis" {
    name = "allow-redis"
    network = var.vpc.network_name

    allow {
        protocol = "tcp"
        ports = ["6379"]
    }

    source_ranges = [var.vpc.fleet_range]
    target_tags = ["redis"]
}

resource "google_compute_instance" "instance" {
    name = "fleet-redis-instance"
    machine_type = "e2-micro"

    tags = google_compute_firewall.redis.target_tags

    boot_disk {
        initialize_params {
            image = "cos-cloud/cos-121-lts"
        }
    }
    
    network_interface {
        subnetwork = var.vpc.compute_subnet
    }

    metadata = {
        gce-container-declaration = templatefile("${path.module}/redis.yaml", {
            version = var.redis_version
            password = random_password.password.result
        })
    }
}