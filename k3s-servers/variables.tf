variable "project" {
  type = string
}

variable "network" {
  type = string
}

variable "region" {
  type = string
}

variable "cidr_range" {
}

variable "machine_type" {
  type = string
}

variable "target_size" {
  type = number
  default = 3
}

variable "authorized_networks" {
  type = string
}

variable "service_account" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}
