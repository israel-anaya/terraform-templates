output "gitlab_environment" {
  value       = var.environment
  description = "Environment"
}

output "gitlab_project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "gitlab_region" {
  value       = var.region
  description = "GCloud Region"
}

output "gitlab_main_zone" {
  value       = var.main_zone
  description = "The zone primary to use"
}

output "vm_bastion_ssh" {
  description = "GCloud ssh command to connect to the Bastion instance."
  value       = module.vm_bastion.ssh
}
