output "ip_address" {
    value = google_compute_instance.instance.network_interface.0.network_ip
}

output "password" {
    value = random_password.password.result
    sensitive = true
}