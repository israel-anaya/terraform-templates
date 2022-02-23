
# VPC
resource "google_compute_network" "vpc" {
  name                    = "${local.cluster_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.cluster_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# External IP for Main LoadBalancer
resource "google_compute_address" "ingress_ip" {
  name = "${local.cluster_name}-ip"
  region        = var.region
}