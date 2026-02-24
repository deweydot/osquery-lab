output "server_url" {
    value = module.fleet.url
}

output "enroll_secret" {
    value = module.fleet.enroll_secret
    sensitive = true
}

output "admin_email" {
    value = "TODO"
}

output "admin_password" {
    value = "TODO"
    sensitive = true
}