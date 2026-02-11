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
    version = "REDIS_7_0"
}

module "fleet" {
    source = "../fleet"
    location = var.region
    enroll_secret = random_password.enroll_secret.result

    mysql_address = module.mysql.ip_address
    mysql_password = random_password.mysql_password.result

    redis_address = module.redis.ip_address
    redis_password = random_password.redis_password.result
}