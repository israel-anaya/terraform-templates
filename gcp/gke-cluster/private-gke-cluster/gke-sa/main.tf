// Create the GKE service account
resource "google_service_account" "gke" {
  account_id   = format("%s-node-sa", var.cluster_name)
  display_name = format("%s Node Service Account", upper(var.cluster_name))
  project      = var.project_id
}

// Add the service account to the project
resource "google_project_iam_member" "service-account" {
  count   = length(var.service_account_iam_roles)
  project = var.project_id
  role    = element(var.service_account_iam_roles, count.index)
  member  = format("serviceAccount:%s", google_service_account.gke.email)
}

// Add user-specified roles
resource "google_project_iam_member" "service-account-custom" {
  count   = length(var.service_account_custom_iam_roles)
  project = var.project_id
  role    = element(var.service_account_custom_iam_roles, count.index)
  member  = format("serviceAccount:%s", google_service_account.gke.email)
}

