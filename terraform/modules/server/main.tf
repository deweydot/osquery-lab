resource "google_compute_network" "internal" {
    name = "fleet-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "internal" {
    name = "fleet-subnet"
    ip_cidr_range = "10.0.0.0/28"
    network = google_compute_network.network.id
}

module "mysql" {
    source = "../mysql"
    mysql_version = "latest"
    vpc_subnet = google_compute_subnetwork.internal
}

module "redis" {
    source = "../redis"
    redis_version = "latest"
    vpc_subnet = google_compute_subnetwork.internal
}

module "fleet" {
    source = "../fleet"
    fleet_version = "latest"
    
    mysql_address = module.mysql.ip_address
    mysql_password = module.mysql.password
    
    redis_address = module.redis.ip_address
    redis_password = module.redis.password
    
    location = var.region
    vpc_subnet = google_compute_subnetwork.internal
}