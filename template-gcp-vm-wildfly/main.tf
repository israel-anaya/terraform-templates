provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

module "sa" {
  source      = "./service-account"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}


module "networks" {
  source      = "./networks"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  depends_on  = [module.sa]
}

module "vm_bastion" {
  source          = "./vm-bastion"
  project_id      = var.project_id
  region          = var.region
  zone            = var.main_zone
  environment     = var.environment
  network         = module.networks.network
  subnetwork      = module.networks.subnetwork
  service_account = module.sa.bastion_sa
  machine_type    = var.bastion_machine_type
  depends_on      = [module.sa, module.networks]
}

module "vm_wildfly" {
  source           = "./vm-wildfly"
  project_id       = var.project_id
  region           = var.region
  zone             = var.main_zone
  environment      = var.environment
  network          = module.networks.network
  subnetwork       = module.networks.subnetwork
  bastion_hostname = module.vm_bastion.hostname
  service_account  = module.sa.gitlab_sa
  machine_type     = var.weblogic_machine_type
  depends_on       = [module.sa, module.networks, module.vm_bastion]
}

