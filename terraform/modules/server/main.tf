resource "random_password" "enroll_secret" {
    length  = 32
    special = false
}

resource "random_password" "mysql_password" {
    length  = 32
    special = false
}

resource "random_password" "redis_password" {
    length  = 32
    special = false
}

module "mysql" {
    source = "../mysql"
    password = random_password.mysql_password.result
    version = "MYSQL_8_4"
}

module "redis" {
    source = "../redis"
    password = random_password.redis_password.result
}

module "fleet" {
    source = "../fleet"
    location = var.region
    enroll_secret = random_password.enroll_secret.result

    mysql_address = "TODO"
    mysql_password = random_password.mysql_password.result

    redis_address = "TODO"
    redis_password = random_password.redis_password.result
}