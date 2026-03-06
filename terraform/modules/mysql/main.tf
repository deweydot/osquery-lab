resource "random_password" "password" {
    length  = 32
    special = false
}

resource "google_compute_instance" "instance" {
    name = "fleet-mysql-instance"
    machine_type = "e2-micro"

    tags = ["mysql"]

    boot_disk {
        initialize_params {
            image = "cos-cloud/cos-121-lts"
        }
    }
    
    network_interface {
        subnetwork = var.subnet
    }

    metadata = {
        gce-container-declaration = templatefile("${path.module}/mysql.yaml", {
            version = var.mysql_version
            password = random_password.password.result
        })
    }
}