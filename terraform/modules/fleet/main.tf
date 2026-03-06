resource "random_pet" "admin_passphrase" {
    length = 4
    separator = "-"
}

resource "random_password" "enroll_secret" {
    length  = 32
    special = false
}

resource "google_cloud_run_v2_job" "prepare_db" {
    name     = "fleet-prepare-db"
    location = "us-central1"
    template {
        template {
            containers {
                image = "fleetdm/fleet:${var.fleet_version}"
                command = ["/bin/sh", "-c"]
                args = [file("${path.module}/prepare.sh")]

                env {
                    name = "FLEET_MYSQL_ADDRESS"
                    value = "${var.mysql_address}:3306"
                }
                env {
                    name = "FLEET_MYSQL_PASSWORD"
                    value = var.mysql_password
                }
            }
            
            vpc_access {
                network_interfaces {
                    subnetwork = var.subnet
                }
                egress = "PRIVATE_RANGES_ONLY"
            }
        }
    }
}

resource "google_cloud_run_v2_service" "service" {
    name = "fleet-lab-server"
    location = var.region
    deletion_protection = false
    ingress = "INGRESS_TRAFFIC_ALL"

    depends_on = []

    scaling {
        min_instance_count = 0
        max_instance_count = 1
    }

    template {
        containers {
            image = "fleetdm/fleet:${var.fleet_version}"
            
            env {
                name = "FLEET_MYSQL_ADDRESS"
                value = "${var.mysql_address}:3306"
            }
            env {
                name = "FLEET_MYSQL_PASSWORD"
                value = var.mysql_password
            }
            env { 
                name = "FLEET_REDIS_ADDRESS"
                value = "${var.redis_address}:6379"
            }
            env { 
                name = "FLEET_REDIS_PASSWORD"
                value = var.redis_password
            }
            env {
                name = "FLEET_SERVER_TLS"
                value = false
            }
        }
        vpc_access {
            network_interfaces {
                subnetwork = var.subnet
            }
            egress = "PRIVATE_RANGES_ONLY"
        }
    }

    depends_on = [google_cloud_run_v2_job.prepare_db]
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
    location = google_cloud_run_v2_service.service.location
    name     = google_cloud_run_v2_service.service.name
    role     = "roles/run.invoker"
    member   = "allUsers"
}