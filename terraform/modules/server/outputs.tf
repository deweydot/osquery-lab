output "server_url" {
    value = module.fleet.url
}

output "enroll_secret" {
    value = module.fleet.enroll_secret
    sensitive = true
}

output "admin_email" {
    value = local.admin_email
}

output "admin_password" {
    value = local.admin_password
    sensitive = true
}