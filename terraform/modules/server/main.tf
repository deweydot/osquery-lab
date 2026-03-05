resource "google_compute_network" "internal" {
    name = "fleet-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "compute" {
    name = "fleet-compute-subnet"
    ip_cidr_range = "10.128.0.0/24"
    network = google_compute_network.internal.id
}

resource "google_compute_subnetwork" "run" {
    name = "fleet-run-subnet"
    ip_cidr_range = "10.128.1.0/24"
    network = google_compute_network.internal.id
}

module "mysql" {
    source = "../mysql"
    mysql_version = "latest"
    vpc = {
        network_name = google_compute_network.internal.name
        fleet_range = google_compute_subnetwork.run.ip_cidr_range
        compute_subnet = google_compute_subnetwork.compute.id
    }
}

module "redis" {
    source = "../redis"
    redis_version = "latest"
    vpc = {
        network_name = google_compute_network.internal.name
        fleet_range = google_compute_subnetwork.run.ip_cidr_range
        compute_subnet = google_compute_subnetwork.compute.id
    }
}

module "fleet" {
    source = "../fleet"
    fleet_version = "latest"
    
    mysql_address = module.mysql.ip_address
    mysql_password = module.mysql.password
    
    redis_address = module.redis.ip_address
    redis_password = module.redis.password
    
    location = var.region
    run_subnet = google_compute_subnetwork.run.id
}