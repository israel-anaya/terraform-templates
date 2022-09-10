locals {
  cluster_name = "${var.project_id}-${var.environment}-gke"
}

provider "google" {
  project = var.project_id
  region  = var.region
}