resource "random_string" "token" {
  length  = 32
  special = false
}

data "template_file" "k3s-server-startup-script" {
  template = file("${path.module}/templates/server.sh")
  vars = {
    token                  = random_string.token.result
    internal_lb_ip_address = google_compute_address.k3s-api-server-internal.address
    external_lb_ip_address = google_compute_address.k3s-api-server-external.address
    db_host                = var.db_host
    db_name                = var.db_name
    db_user                = var.db_user
    db_password            = var.db_password
  }
}

resource "google_compute_instance_template" "k3s-server" {
  name_prefix  = "k3s-server-"
  machine_type = var.machine_type

  tags = ["k3s", "k3s-server"]

  metadata_startup_script = data.template_file.k3s-server-startup-script.rendered

  metadata = {
    block-project-ssh-keys = "TRUE"
    enable-oslogin         = "TRUE"
  }

  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network
    subnetwork = google_compute_subnetwork.k3s-servers.id
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "k3s-servers" {
  name = "k3s-servers"

  base_instance_name = "k3s-server"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.k3s-server.id
  }

  target_size = var.target_size

  named_port {
    name = "k3s"
    port = 6443
  }

  depends_on = [google_compute_router_nat.nat]
}
