
// Dedicated service account for the gitlab instance.
resource "google_service_account" "gitlab" {
  account_id   = format("%s-gitlab-sa", var.environment)
  display_name = "GitLab Instance Service Account"
}

resource "google_project_iam_member" "role_cloudsql_editor" {
  project = var.project_id
  role    = "roles/cloudsql.editor"
  member  = "serviceAccount:${google_service_account.gitlab.email}"
}

resource "google_service_account_key" "gitlab_key" {
  service_account_id = google_service_account.gitlab.name
}
