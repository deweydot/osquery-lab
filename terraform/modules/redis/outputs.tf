output "ip_address" {
    value = google_redis_instance.instance.host
}

output "password" {
    value = google_redis_instance.instance.auth_string
    sensitive = true
}