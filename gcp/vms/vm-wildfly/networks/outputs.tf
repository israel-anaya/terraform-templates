output "network" {
  value       = google_compute_network.vpc
  description = "The VPC"
}

output "subnetwork" {
  value       = google_compute_subnetwork.subnetwork
  description = "The subnetwork"
}
