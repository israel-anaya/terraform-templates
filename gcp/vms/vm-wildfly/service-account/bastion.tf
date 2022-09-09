// Dedicated service account for the Bastion instance.
resource "google_service_account" "bastion" {
  account_id   = format("%s-bastion-sa", var.environment)
  display_name = "GitLab Bastion Service Account"
}

resource "google_project_iam_member" "role_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "role_aim_serviceaccount" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_service_account_key" "bastion_key" {
  service_account_id = google_service_account.bastion.name
}