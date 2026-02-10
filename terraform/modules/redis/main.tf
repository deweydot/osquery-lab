resource "google_redis_instance" "instance" {
    name = "memory-cache"
    tier = "BASIC"
    memory_size_gb = 1
    deletion_protection = false

    displayName = "terraform-redis"

    lifecycle {
        prevent_destroy = true
    }
}