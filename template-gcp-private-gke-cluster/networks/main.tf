
// Create a network for GKE
resource "google_compute_network" "vpc" {
  project                         = var.project_id
  name                            = format("%s-vpc", var.cluster_name)
  auto_create_subnetworks         = false
}


// Create subnets
resource "google_compute_subnetwork" "subnetwork" {
  name          = format("%s-subnet", var.cluster_name)
  network       = google_compute_network.vpc.name
  project       = var.project_id
  region        = var.region
  ip_cidr_range = "10.0.0.0/24"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = format("%s-pod-range", var.cluster_name)
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = format("%s-svc-range", var.cluster_name)
    ip_cidr_range = "10.2.0.0/20"
  }
}

// Create an external NAT IP
resource "google_compute_address" "nat" {
  name    = format("%s-nat-ip", var.cluster_name)
  project = var.project_id
  region  = var.region

}

// Create a cloud router for use by the Cloud NAT
resource "google_compute_router" "router" {
  name    = format("%s-cloud-router", var.cluster_name)
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.name

  bgp {
    asn = 64514
  }
}

// Create a NAT router so the nodes can reach DockerHub, etc
resource "google_compute_router_nat" "nat" {
  name    = format("%s-cloud-nat", var.cluster_name)
  router  = google_compute_router.router.name
  project = var.project_id
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat.name]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnetwork.name
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = [
      google_compute_subnetwork.subnetwork.secondary_ip_range.0.range_name,
      google_compute_subnetwork.subnetwork.secondary_ip_range.1.range_name,
    ]
  }
}

# External IP for Main LoadBalancer
resource "google_compute_address" "ingress_ip" {
  name    = "${var.cluster_name}-ingress-ip"
  project = var.project_id
  region  = var.region
}