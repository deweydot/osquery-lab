module "mysql" {
    source = "../mysql"
    region = var.region
    mysql_version = "latest"
}

module "redis" {
    source = "../redis"
    region = var.region
    redis_version = "latest"
}

/*
module "fleet" {
    source = "../fleet"
    region = var.region
    fleet_version = "latest"
    
    mysql_address = module.mysql.ip_address
    mysql_password = module.mysql.password
    
    redis_address = module.redis.ip_address
    redis_password = module.redis.password
}
*/