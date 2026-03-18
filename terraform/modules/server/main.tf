resource "google_compute_network" "network" {
    name = "fleet-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
    name = "fleet-subnet"
    ip_cidr_range = "10.128.0.0/24"
    network = google_compute_network.network.id
}

resource "google_compute_firewall" "fleet" {
    name = "allow-web-server"
    network = google_compute_network.network.name
    
    allow {
        protocol = "tcp"
        ports = ["8080"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["fleet-server"]
}

resource "google_compute_router" "router" {
    name = "fleet-router"
    network = google_compute_network.network.name
}

resource "google_compute_address" "internal" {
    name = "server-internal"
    subnetwork = google_compute_subnetwork.subnet.id
    address_type = "INTERNAL"
}

resource "google_compute_address" "external" {
    name = "server-external"
    address_type = "EXTERNAL"
}

resource "google_compute_router_nat" "nat" {
    name = "fleet-router-nat"
    router = "fleet-router"
    nat_ip_allocate_option = "AUTO_ONLY"

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name = google_compute_subnetwork.subnet.id
        source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
    }
}

resource "random_password" "mysql" {
    length = 32
    special = false
}

resource "random_password" "redis" {
    length = 32
    special = false
}

resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 2048
}

resource "tls_self_signed_cert" "cert" {
    private_key_pem = tls_private_key.key.private_key_pem

    ip_addresses = [
        google_compute_address.internal.address
        google_compute_address.external.address
    ]

    subject {
        common_name = google_compute_address.external.address
    }

    validity_period_hours = 8760

    allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
    ]
}

resource "google_compute_instance" "instance" {
    name         = "server-vm"
    machine_type = "e2-medium"

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
        }
    }
    
    network_interface {
        subnetwork = google_compute_subnetwork.subnet.id
        network_ip = google_compute_address.internal.address
        access_config {
            nat_ip = google_compute_address.external.address
        }
    }

    metadata_startup_script = templatefile("${path.module}/startup.sh", {
        cert_pem = tls_self_signed_cert.cert.cert_pem
        key_pem = tls_private_key.key.private_key_pem
        enroll_secret = "CHANGEME"
        docker_compose = templatefile("${path.module}/compose.yaml", {
            mysql_password = random_password.mysql.result
            redis_password = random_password.redis.result
            admin_password = "CHANGEME"
        })
    })
}