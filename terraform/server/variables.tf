variable "enroll_secret" {
    type = string
}

variable "admin_password" {
    type = string
}

variable "fleet_version" {
    type = string
    default = "melpike-patch-6"
}

variable "mysql_version" {
    type = string
    default = "8.0-debian"
}

variable "redis_version" {
    type = string
    default = "7.0-alpine"
}