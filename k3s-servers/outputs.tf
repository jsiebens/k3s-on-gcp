output "token" {
  value = random_string.token.result
}

output "internal_lb_ip_address" {
  value = google_compute_address.k3s-api-server-internal.address
}

output "external_lb_ip_address" {
  value = google_compute_address.k3s-api-server-external.address
}
