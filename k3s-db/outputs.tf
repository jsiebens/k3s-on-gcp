output "db_host" {
  value = google_sql_database_instance.k3s-db.private_ip_address
}

output "db_name" {
  value = google_sql_database.k3s-db.name
}

output "db_user" {
  value = google_sql_user.k3s.name
}

output "db_password" {
  value = google_sql_user.k3s.password
}
