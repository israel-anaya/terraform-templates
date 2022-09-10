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

module "database_service" {
  source      = "./database-service"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  network     = module.networks.network
  subnetwork  = module.networks.subnetwork
  tier        = var.database_tier
  depends_on  = [module.sa, module.networks]
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

module "vm_gitlab" {
  source           = "./vm-gitlab"
  project_id       = var.project_id
  region           = var.region
  zone             = var.main_zone
  environment      = var.environment
  network          = module.networks.network
  subnetwork       = module.networks.subnetwork
  bastion_hostname = module.vm_bastion.hostname
  service_account  = module.sa.gitlab_sa
  machine_type     = var.gitlab_machine_type
  depends_on       = [module.sa, module.networks, module.vm_bastion]
}

module "vm_sonarqube" {
  source           = "./vm-sonarqube"
  project_id       = var.project_id
  region           = var.region
  zone             = var.main_zone
  environment      = var.environment
  network          = module.networks.network
  subnetwork       = module.networks.subnetwork
  bastion_hostname = module.vm_bastion.hostname
  gitlab_hostname  = module.vm_gitlab.hostname
  service_account  = module.sa.gitlab_sa
  machine_type     = var.sonarqube_machine_type
  depends_on       = [module.sa, module.networks, module.vm_bastion, module.vm_gitlab]
}

module "vm_workers" {
  source            = "./vm-workers"
  project_id        = var.project_id
  region            = var.region
  zone              = var.main_zone
  environment       = var.environment
  network           = module.networks.network
  subnetwork        = module.networks.subnetwork
  bastion_hostname  = module.vm_bastion.hostname
  allow_db_hostname = [module.vm_gitlab.hostname, module.vm_sonarqube.hostname]
  service_account   = module.sa.gitlab_sa
  machine_type      = var.workers_machine_type
  connection_name   = module.database_service.connection_name
  depends_on        = [module.sa, module.networks, module.vm_bastion, module.vm_gitlab]
}

