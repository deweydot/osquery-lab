output "uri" {
    value = google_sql_database_instance.instance.self_link
}

output "password" {
    value = random_password.password.result
}