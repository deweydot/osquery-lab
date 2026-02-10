output "server_url" {
    value = module.fleet.uri
}

output "enroll_secret" {
    value = random_password.enroll_secret.result
}