output "ip_address" {
    value = google_sql_database_instance.instance.public_ip_address
}