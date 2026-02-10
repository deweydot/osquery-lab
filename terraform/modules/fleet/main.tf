locals {
    mysql_database = "fleet"
    mysql_username = "fleet"
    redis_username = "fleet"
}

module "server" {
    source = "../modules/fleet"
    location = var.region
}

module "mysql" {
    source = "../mysql"
    database = local.mysql_database
    username = local.mysql_username
    version = "MYSQL_8_4"
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
            image = "fleetdm/fleet:latest"
            
            env {
                name = "FLEET_MYSQL_ADDRESS"
                value = "TODO"
            }
            env {
                name = "FLEET_MYSQL_DATABASE"
                value = local.mysql_database
            }
            env {
                name = "FLEET_MYSQL_USERNAME"
                value = local.mysql_username
            }
            env {
                name = "FLEET_MYSQL_PASSWORD"
                value = module.mysql.password
            }
            env { 
                name = "FLEET_REDIS_ADDRESS"
                value = "TODO"
            }
            env { 
                name = "FLEET_REDIS_USERNAME"
                value = local.redis_username
            }
            env { 
                name = "FLEET_REDIS_PASSWORD"
                value = "TODO"
            }
            env {
                name = "FLEET_SERVER_TLS"
                value = false
            }
        }
    }
}

resource "random_password" "enroll_secret" {
    length  = 32
    special = false
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
    location = google_cloud_run_v2_service.service.location
    name     = google_cloud_run_v2_service.service.name
    role     = "roles/run.invoker"
    member   = "allUsers"
}