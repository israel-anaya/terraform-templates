output "bastion_open_tunnel_command" {
  description = "Command that opens an SSH tunnel to the Bastion instance."
  value       = module.bastion.ssh
}

output "kubectl_alias_command" {
  description = "Command that creates an alias for kubectl using Bastion as proxy. Bastion ssh tunnel must be running."
  value       = module.bastion.kubectl_command
}

output "cluster_environment" {
  value       = var.environment
  description = "Environment"
}

output "cluster_project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "cluster_region" {
  value       = var.region
  description = "GCloud Region"
}

output "cluster_main_zone" {
  value       = var.main_zone
  description = "The zone primary to use"
}

output "cluster_network_id" {
  value       = module.gke_networks.network.id
  description = "Network ID"
}

output "kubernetes_cluster_name" {
  value       = module.gke_cluster.kubernetes_cluster_name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = module.gke_cluster.kubernetes_cluster_host
  description = "GKE Cluster Host"
}

output "kubernetes_cluster_ingress_ip" {
  value       = module.gke_networks.kubernetes_cluster_ingress_ip
  description = "GKE Cluster Ingress IP address"
}
