resource "random_password" "password" {
    length  = 32
    special = false
}

resource "google_compute_firewall" "mysql" {
    name = "allow-mysql"
    network = var.vpc.network_name
    
    allow {
        protocol = "tcp"
        ports = ["3306"]
    }

    source_ranges = [var.vpc.fleet_range]
    target_tags = ["mysql"]
}

resource "google_compute_instance" "instance" {
    name = "fleet-mysql-instance"
    machine_type = "e2-micro"

    tags = google_compute_firewall.mysql.target_tags

    boot_disk {
        initialize_params {
            image = "cos-cloud/cos-121-lts"
        }
    }
    
    network_interface {
        subnetwork = var.vpc.compute_subnet
    }

    metadata = {
        gce-container-declaration = templatefile("${path.module}/mysql.yaml", {
            version = var.mysql_version
            password = random_password.password.result
        })
    }
}