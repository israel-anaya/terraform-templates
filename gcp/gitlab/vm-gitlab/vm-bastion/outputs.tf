output "hostname" {
  value       = local.hostname
  description = "The hostname tag of the Bastion instance."
}

output "ssh" {
  description = "GCloud ssh command to connect to the Bastion instance."
  value       = "gcloud compute ssh ${google_compute_instance.instance.name} --project ${var.project_id} --zone ${google_compute_instance.instance.zone} -- -L8888:127.0.0.1:8888"
}