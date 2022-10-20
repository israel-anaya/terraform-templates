locals {
  psa_config = {
    ranges = {
      range         = "10.101.0.0/22"
      support-range = "10.102.0.0/28"
    }
    routes = {
      export = true
      import = false
    }
  }
}

// Create a network for GKE
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = format("%s-vpc", var.apigee_name)
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

// Create subnets
resource "google_compute_subnetwork" "subnetwork" {
  name          = format("%s-subnet", var.apigee_name)
  network       = google_compute_network.vpc.name
  project       = var.project_id
  region        = var.region
  ip_cidr_range = "10.100.0.0/28"

  private_ip_google_access = true

}

resource "google_compute_global_address" "apigee_ranges" {
  for_each      = local.psa_config.ranges
  project       = var.project_id
  name          = format("%s-%s-ip", var.apigee_name, each.key)
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", each.value)[0]
  prefix_length = split("/", each.value)[1]
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  for_each = local.psa_config == null ? {} : { 1 = 1 }
  network  = google_compute_network.vpc.id
  service  = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    for k, v in google_compute_global_address.apigee_ranges : v.name
  ]
}

# resource "google_compute_network_peering_routes_config" "psa_routes" {
#   for_each             = local.psa_config == null ? {} : { 1 = 1 }
#   project              = var.project_id
#   peering              = google_service_networking_connection.apigee_vpc_connection["1"].peering
#   network              = google_compute_network.vpc.id
#   export_custom_routes = try(local.psa_config.routes.export, false)
#   import_custom_routes = try(local.psa_config.routes.import, false)
# }

module "peering_apigee_gke" {
  source = "./peering"

  prefix                     = "apigee-gke"
  local_network              = google_compute_network.vpc.id
  peer_network               = var.peer_network
  export_local_custom_routes = true
  module_depends_on          = [google_compute_network.vpc]
}





