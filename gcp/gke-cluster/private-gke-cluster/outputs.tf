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
  value       = var.enable_autopilot ? module.gke_cluster_autopilot.0.kubernetes_cluster_name : module.gke_cluster.0.kubernetes_cluster_name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = var.enable_autopilot ? module.gke_cluster_autopilot.0.kubernetes_cluster_host : module.gke_cluster.0.kubernetes_cluster_host
  description = "GKE Cluster Host"
}

output "kubectl_alias_command" {
  description = "Command that creates an alias for kubectl using Bastion as proxy. Bastion ssh tunnel must be running."
  value       = module.bastion.kubectl_command
}

output "bastion_open_tunnel_command" {
  description = "Command that opens an SSH tunnel to the Bastion instance."
  value       = module.bastion.ssh
}

