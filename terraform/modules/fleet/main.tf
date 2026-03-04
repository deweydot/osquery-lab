resource "random_pet" "admin_passphrase" {
    length = 4
    separator = "-"
}

resource "random_password" "enroll_secret" {
    length  = 32
    special = false
}

resource "google_cloud_run_v2_service" "service" {
    name = "fleet-lab-server"
    location = var.location
    deletion_protection = false
    ingress = "INGRESS_TRAFFIC_ALL"

    scaling {
        min_instance_count = 0
        max_instance_count = 2
    }

    template {
        containers {
            image = "fleetdm/fleet:${var.fleet_version}"
            
            env {
                name = "FLEET_MYSQL_ADDRESS"
                value = var.mysql_address
            }
            env {
                name = "FLEET_MYSQL_PASSWORD"
                value = var.mysql_password
            }
            env { 
                name = "FLEET_REDIS_ADDRESS"
                value = var.redis_address
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
                subnetwork = var.vpc_subnet
            }
            egress = "ALL_TRAFFIC"
        }
    }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
    location = google_cloud_run_v2_service.service.location
    name     = google_cloud_run_v2_service.service.name
    role     = "roles/run.invoker"
    member   = "allUsers"
}