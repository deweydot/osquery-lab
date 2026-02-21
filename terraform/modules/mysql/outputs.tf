output "ip_address" {
    value = google_sql_database_instance.instance.private_ip_address
}

output "password" {
    value = random_password.password.result
    sensitive = true
}