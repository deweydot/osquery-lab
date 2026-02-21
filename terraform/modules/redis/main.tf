resource "google_redis_instance" "instance" {
    name = "memory-cache"
    tier = "BASIC"
    memory_size_gb = 1

    redis_version = var.redis_version
    display_name = "fleet"
    auth_enabled = true
    authorized_network = var.private_network

    lifecycle {
        prevent_destroy = true
    }
}