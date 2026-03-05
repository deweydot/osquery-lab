variable "mysql_version" {
    type = string
}

variable "vpc" {
    type = object({
        network_name = string
        fleet_range = string
        compute_subnet  = string
    })
}
