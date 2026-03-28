output "external_ip" {
    value = module.server.external_ip
}

output "admin_password" {
    value = random_password.admin.result
    sensitive = true
}