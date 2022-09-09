locals {
  cluster_name = "${var.instance_name}-gke"
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
  source = "./networks"
  project_id   = var.project_id
  region       = var.region
  cluster_name = local.cluster_name

}

module "gke_cluster" {
  source = "./gke-cluster"

  project_id   = var.project_id
  region       = var.region
  node_zones   = var.cluster_node_zones
  cluster_name = local.cluster_name
  machine_type = var.machine_type
  node_count   = var.node_count
  #service_account            = var.service_account
  network                    = module.gke_networks.network
  subnetwork                 = module.gke_networks.subnetwork
  #master_ipv4_cidr_block     = module.gke_networks.cluster_master_ip_cidr_range
  #pods_ipv4_cidr_block       = module.gke_networks.cluster_pods_ip_cidr_range
  #services_ipv4_cidr_block   = module.gke_networks.cluster_services_ip_cidr_range
  authorized_ipv4_cidr_block = "${module.bastion.ip}/32"

}

module "bastion" {
  source = "./bastion"

  project_id   = var.project_id
  region       = var.region
  zone         = var.main_zone
  cluster_name = local.cluster_name
  network_name = module.gke_networks.network.name
  subnetwork_name  = module.gke_networks.subnetwork.name
}

module "admin" {
  source = "./vm-admin"

  project_id   = var.project_id
  region       = var.region
  zone         = var.main_zone
  cluster_name = local.cluster_name
  network_name = module.gke_networks.network.name
  subnetwork_name  = module.gke_networks.subnetwork.name
}
