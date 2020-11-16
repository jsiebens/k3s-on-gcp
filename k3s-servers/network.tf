resource "google_compute_subnetwork" "k3s-servers" {
  name          = "k3s-servers"
  network       = var.network
  region        = var.region
  ip_cidr_range = var.cidr_range

  private_ip_google_access = true
}

resource "google_compute_address" "k3s-api-server-internal" {
  name         = "k3s-api-server-internal"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  region       = var.region
  subnetwork   = google_compute_subnetwork.k3s-servers.id
}

resource "google_compute_address" "k3s-api-server-external" {
  name   = "k3s-api-server-external"
  region = var.region
}

resource "google_compute_firewall" "k3s-api-allow-hc" {
  name          = "k3s-api-allow-hc"
  network       = var.network
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
  allow {
    protocol = "tcp"
    ports    = [6443]
  }
  target_tags = ["k3s-server"]
  direction   = "INGRESS"
}

resource "google_compute_firewall" "k3s-api-authorized-networks" {
  name          = "k3s-api-authorized-networks"
  network       = var.network
  source_ranges = split(",", var.authorized_networks)
  allow {
    protocol = "tcp"
    ports    = [6443]
  }
  target_tags = ["k3s-server"]
  direction   = "INGRESS"
}

resource "google_compute_router" "router" {
  name    = "k3s-servers"
  region  = var.region
  network = var.network
}

resource "google_compute_router_nat" "nat" {
  name                               = "k3s-servers"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.k3s-servers.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
