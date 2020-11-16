variable "project" {
  type = string
}

variable "name" {
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
  type    = number
  default = 3
}

variable "token" {
}

variable "server_address" {
}

variable "service_account" {
}
