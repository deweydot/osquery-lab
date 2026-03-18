output "subnet" {
    value = google_compute_subnetwork.subnet.id
}

output "internal_ip" {
    value = google_compute_address.internal.address
}

output "external_ip" {
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