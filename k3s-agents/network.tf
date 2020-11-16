resource "google_compute_subnetwork" "k3s-agents" {
  name          = "k3s-agents-${var.name}"
  network       = var.network
  region        = var.region
  ip_cidr_range = var.cidr_range

  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "k3s-agents-${var.name}"
  region  = var.region
  network = var.network
}

resource "google_compute_router_nat" "nat" {
  name                               = "k3s-agents-${var.name}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.k3s-agents.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
