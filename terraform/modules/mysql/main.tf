resource "google_sql_database" "database" {
    name = var.database
    instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
    database_version = var.version
    settings {
        tier = "db-f1-micro"
    }
}

resource "random_password" "password" {
    length  = 32
    special = false
}

resource "google_sql_user" "users" {
    name = var.username
    instance = google_sql_database_instance.instance.name
    password = random_password.password.result
}