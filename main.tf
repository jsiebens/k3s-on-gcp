terraform {
  required_version = ">= 0.13"

  required_providers {
    google = ">= 3.3"
  }
}

provider "google" {
  project = var.project
}

resource "google_compute_network" "k3s" {
  name                    = "k3s"
  auto_create_subnetworks = "false"
}

resource "google_compute_firewall" "k3s-firewall" {
  name    = "k3s-allow-internal"
  network = google_compute_network.k3s.id
  allow {
    protocol = "all"
  }
  source_tags = ["k3s"]
  target_tags = ["k3s"]
}

resource "google_compute_firewall" "iap-firewall" {
  name    = "iap-allow-ssh"
  network = google_compute_network.k3s.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["k3s"]
}


resource "google_service_account" "k3s-server" {
  account_id = "k3s-server"
}

resource "google_service_account" "k3s-agent" {
  account_id = "k3s-agent"
}

module "k3s-db" {
  source = "./k3s-db"

  project = var.project
  network = google_compute_network.k3s.self_link
  region  = var.database.region
  db_tier = var.database.tier
}

module "k3s-servers" {
  source = "./k3s-servers"

  project             = var.project
  network             = google_compute_network.k3s.self_link
  region              = var.servers.region
  cidr_range          = var.servers.cidr_range
  machine_type        = var.servers.machine_type
  target_size         = var.servers.target_size
  authorized_networks = var.servers.authorized_networks
  service_account     = google_service_account.k3s-server.email

  db_host     = module.k3s-db.db_host
  db_name     = module.k3s-db.db_name
  db_user     = module.k3s-db.db_user
  db_password = module.k3s-db.db_password
}

module "k3s-agents" {
  source   = "./k3s-agents"
  for_each = var.agents

  project         = var.project
  name            = each.key
  network         = google_compute_network.k3s.self_link
  region          = each.value.region
  cidr_range      = each.value.cidr_range
  machine_type    = each.value.machine_type
  target_size     = each.value.target_size
  token           = module.k3s-servers.token
  server_address  = module.k3s-servers.internal_lb_ip_address
  service_account = google_service_account.k3s-agent.email
}

