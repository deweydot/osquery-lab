output "ip_address" {
    value = google_redis_instance.instance.host
}