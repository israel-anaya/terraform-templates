locals {
  cluster_name = var.enable_autopilot ? "${var.instance_name}-gkeap" : "${var.instance_name}-gke"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

module "gke_networks" {
  source       = "./networks"
  project_id   = var.project_id
  region       = var.region
  cluster_name = local.cluster_name

}

module "gke_service_account" {
  source = "./gke-sa"
  project_id   = var.project_id
  cluster_name = local.cluster_name
}

module "gke_cluster" {
  count  = var.enable_autopilot == false ? 1 : 0
  source = "./gke-cluster"

  project_id                 = var.project_id
  region                     = var.region
  service_account            = module.gke_service_account.email
  node_zones                 = var.cluster_node_zones
  cluster_name               = local.cluster_name
  machine_type               = var.machine_type
  node_count                 = var.node_count
  network                    = module.gke_networks.network
  subnetwork                 = module.gke_networks.subnetwork
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"

}


module "gke_cluster_autopilot" {
  count  = var.enable_autopilot == true ? 1 : 0
  source = "./gke-cluster-autopilot"

  project_id                 = var.project_id
  region                     = var.region
  service_account            = module.gke_service_account.email
  node_zones                 = var.cluster_node_zones
  cluster_name               = local.cluster_name
  machine_type               = var.machine_type
  node_count                 = var.node_count
  network                    = module.gke_networks.network
  subnetwork                 = module.gke_networks.subnetwork
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"

}


module "bastion" {
  source = "./bastion"

  project_id      = var.project_id
  region          = var.region
  zone            = var.main_zone
  cluster_name    = local.cluster_name
  network_name    = module.gke_networks.network.name
  subnetwork_name = module.gke_networks.subnetwork.name
}

module "admin" {
  source = "../../vms/vm-admin"

  project_id      = var.project_id
  region          = var.region
  zone            = var.main_zone
  prefix_name     = local.cluster_name
  network_name    = module.gke_networks.network.name
  subnetwork_name = module.gke_networks.subnetwork.name
}
