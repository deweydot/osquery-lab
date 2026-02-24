resource "random_password" "password" {
    length  = 32
    special = false
}

resource "google_sql_database" "database" {
    name = "fleet"
    instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
    database_version = var.mysql_version
    deletion_protection = false

    settings {
        tier = "db-f1-micro"
        edition = "ENTERPRISE"

        ip_configuration {
            ipv4_enabled = false
            private_network = var.private_network
        }
    }
}

resource "google_sql_user" "users" {
    name = "fleet"
    instance = google_sql_database_instance.instance.name
    password = random_password.password.result
}