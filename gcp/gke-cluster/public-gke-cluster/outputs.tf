output "cluster_environment" {
  value       = var.environment
  description = "Environment"
}

output "cluster_region" {
  value       = var.region
  description = "GCloud Region"
}

output "cluster_project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubernetes_cluster_ingress_ip" {
  value       = google_compute_address.ingress_ip.address
  description = "GKE Cluster Ingress IP address"
}

