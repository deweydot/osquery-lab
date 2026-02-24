resource "google_compute_network" "network" {
    name = "fleet-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
    name = "fleet-subnet"
    ip_cidr_range = "10.0.0.0/28"
    network = google_compute_network.network.id
}

resource "google_compute_global_address" "private_ips" {
    name = "fleet-databases"
    prefix_length = 16
    address_type = "INTERNAL"
    purpose = "VPC_PEERING"
    network = google_compute_network.network.id
}

resource "google_service_networking_connection" "private_connection" {
    network = google_compute_network.network.id
    service = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.private_ips.name]
}

resource "google_vpc_access_connector" "vpc_connector" {
    name = "fleet-vpc"
    min_instances = 2
    max_instances = 3
    subnet {
        name = google_compute_subnetwork.subnet.name
    }
}

module "mysql" {
    source = "../mysql"
    mysql_version = "MYSQL_8_4"
    private_network = google_compute_network.network.self_link
    depends_on = [google_service_networking_connection.private_connection]
}

module "redis" {
    source = "../redis"
    redis_version = "REDIS_7_0"
    private_network = google_compute_network.network.self_link
    depends_on = [google_service_networking_connection.private_connection]
}

module "fleet" {
    source = "../fleet"
    location = var.region

    mysql_address = module.mysql.ip_address
    mysql_password = module.mysql.password

    redis_address = module.redis.ip_address
    redis_password = module.redis.password
    
    vpc_connector = google_vpc_access_connector.vpc_connector.id
}