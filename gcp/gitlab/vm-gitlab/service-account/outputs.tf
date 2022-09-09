output "bastion_sa" {
  value = google_service_account.bastion
}

output "gitlab_sa" {
  value = google_service_account.gitlab
}

