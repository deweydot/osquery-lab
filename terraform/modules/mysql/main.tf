resource "google_sql_database" "database" {
    name = "fleet"
    instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
    database_version = var.version
    settings {
        tier = "db-f1-micro"
    }
}

resource "google_sql_user" "users" {
    name = "fleet"
    instance = google_sql_database_instance.instance.name
    password = var.password
}