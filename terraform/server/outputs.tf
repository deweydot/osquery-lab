output "subnet" {
    value = google_compute_subnetwork.subnet.id
}

output "certificate" {
    value = tls_self_signed_cert.cert.cert_pem
}

output "internal_ip" {
    value = google_compute_address.internal.address
}

output "external_ip" {
    value = google_compute_address.external.address
}