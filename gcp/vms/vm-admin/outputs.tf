output "ip" {
  value       = google_compute_instance.admin.network_interface.0.network_ip
  description = "The IP address of the Admin instance."
}
