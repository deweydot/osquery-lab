provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

resource "google_compute_network" "network" {
    name = "fleet-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "compute" {
    name = "fleet-compute-subnet"
    ip_cidr_range = "10.128.0.0/24"
    network = google_compute_network.network.id
}

resource "google_compute_subnetwork" "run" {
    name = "fleet-run-subnet"
    ip_cidr_range = "10.128.1.0/24"
    network = google_compute_network.network.id
}

resource "google_compute_firewall" "mysql" {
    name = "allow-mysql"
    network = google_compute_network.network.name
    
    allow {
        protocol = "tcp"
        ports = ["3306"]
    }

    source_ranges = [google_compute_subnetwork.run.ip_cidr_range]
    target_tags = ["mysql"]
}

resource "google_compute_firewall" "redis" {
    name = "allow-redis"
    network = google_compute_network.network.name

    allow {
        protocol = "tcp"
        ports = ["6379"]
    }

    source_ranges = [google_compute_subnetwork.run.ip_cidr_range]
    target_tags = ["redis"]
}

resource "google_compute_router" "router" {
    name = "fleet-router"
}

resource "google_compute_router_nat" "nat" {
    name = "fleet-router-nat"
    router = google_compute_router.router.name
    nat_ip_allocate_option = "AUTO_ONLY"

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name = google_compute_subnetwork.compute.id
        source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
    }
}