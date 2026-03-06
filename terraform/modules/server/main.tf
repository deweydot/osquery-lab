data "google_compute_subnetwork" "run" {
    name = "fleet-run-subnet"
    region = var.region
}

data "google_compute_subnetwork" "compute" {
    name = "fleet-compute-subnet"
    region = var.region
}

module "mysql" {
    source = "../mysql"
    region = var.region
    subnet = data.google_compute_subnetwork.compute.id
    mysql_version = "latest"
}

module "redis" {
    source = "../redis"
    region = var.region
    subnet = data.google_compute_subnetwork.compute.id
    redis_version = "latest"
}

module "fleet" {
    source = "../fleet"
    region = var.region
    subnet = data.google_compute_subnetwork.run.id
    fleet_version = "latest"
    mysql_address = module.mysql.ip_address
    mysql_password = module.mysql.password
    redis_address = module.redis.ip_address
    redis_password = module.redis.password
}