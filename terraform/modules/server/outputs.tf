output "ip_address" {
    value = google_compute_address.external.address
}

output "enroll_secret" {
    value = "CHANGEME"
    sensitive = true
}

output "admin_password" {
    value = "TODO"
    sensitive = true
}