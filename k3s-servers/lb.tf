resource "google_compute_health_check" "k3s-health-check-internal" {
  name = "k3s-servers-internal-hc"

  timeout_sec        = 1
  check_interval_sec = 5

  tcp_health_check {
    port = 6443
  }
}

resource "google_compute_region_health_check" "k3s-health-check-external" {
  name   = "k3s-servers-external-hc"
  region = var.region

  timeout_sec        = 1
  check_interval_sec = 5

  tcp_health_check {
    port = 6443
  }
}

resource "google_compute_region_backend_service" "k3s-api-server-internal" {
  name                  = "k3s-api-server-internal"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.k3s-health-check-internal.id]
  backend {
    group = google_compute_region_instance_group_manager.k3s-servers.instance_group
  }
}

resource "google_compute_forwarding_rule" "k3s-api-server-internal" {
  name                  = "k3s-api-server-internal"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  allow_global_access   = true
  ip_address            = google_compute_address.k3s-api-server-internal.address
  backend_service       = google_compute_region_backend_service.k3s-api-server-internal.id
  ports                 = [6443]
  subnetwork            = google_compute_subnetwork.k3s-servers.self_link
}

resource "google_compute_region_backend_service" "k3s-api-server-external" {
  name                  = "k3s-api-server-external"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.k3s-health-check-external.id]
  backend {
    group = google_compute_region_instance_group_manager.k3s-servers.instance_group
  }
}

resource "google_compute_forwarding_rule" "k3s-api-server-external" {
  name                  = "k3s-api-server-external"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.k3s-api-server-external.address
  backend_service       = google_compute_region_backend_service.k3s-api-server-external.id
  port_range            = "6443-6443"
}
