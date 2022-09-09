output "network" {
  value       = google_compute_network.vpc
  description = "The VPC"
}

output "subnetwork" {
  value       = google_compute_subnetwork.subnetwork
  description = "The subnetwork"
}

output "kubernetes_cluster_ingress_ip" {
  value       = google_compute_address.ingress_ip.address
  description = "GKE Cluster Ingress IP address"
}