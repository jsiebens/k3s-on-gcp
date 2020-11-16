resource "random_id" "k3s-db" {
  prefix      = "k3s-db-"
  byte_length = 4
}

resource "google_sql_database_instance" "k3s-db" {
  name             = random_id.k3s-db.hex
  region           = var.region
  database_version = "POSTGRES_11"

  settings {
    tier              = var.db_tier
    availability_type = "REGIONAL"
    disk_size         = 50
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = var.network
    }

    backup_configuration {
      enabled    = true
      start_time = "01:00"
    }

    maintenance_window {
      day  = 6
      hour = 1
    }
  }

  depends_on = [google_service_networking_connection.k3s-private-vpc-connection]
}

resource "google_sql_database" "k3s-db" {
  name     = "k3s"
  instance = google_sql_database_instance.k3s-db.name
}

resource "random_password" "k3s-db-pwd" {
  length  = 16
  special = false
}

resource "google_sql_user" "k3s" {
  name     = "k3s"
  instance = google_sql_database_instance.k3s-db.name
  password = random_password.k3s-db-pwd.result
}
