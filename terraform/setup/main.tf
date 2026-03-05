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