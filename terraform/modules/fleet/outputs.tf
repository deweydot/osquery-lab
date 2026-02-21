output "url" {
    value = google_cloud_run_v2_service.service.uri
}

output "enroll_secret" {
    value = random_password.enroll_secret.result
    sensitive = true
}