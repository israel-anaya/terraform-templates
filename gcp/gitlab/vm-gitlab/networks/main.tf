
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = format("%s-vpc", var.environment)
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = format("%s-subnet", var.environment)
  network       = google_compute_network.vpc.name
  project       = var.project_id
  region        = var.region
  ip_cidr_range = "172.16.0.0/12"

  private_ip_google_access = true
}

// Create an external NAT IP
resource "google_compute_address" "nat" {
  name    = format("%s-nat-ip", var.environment)
  project = var.project_id
  region  = var.region
}

// Create a cloud router for use by the Cloud NAT
resource "google_compute_router" "router" {
  name    = format("%s-cloud-router", var.environment)
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.name

  bgp {
    asn = 64514
  }
}

// Create a NAT router so the nodes can reach DockerHub, etc
resource "google_compute_router_nat" "nat" {
  name    = format("%s-cloud-nat", var.environment)
  router  = google_compute_router.router.name
  project = var.project_id
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat.name]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnetwork.name
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
}
