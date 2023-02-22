locals {
  #cluster_issuer_name = "${local.instance_name}-letsencrypt"
  cluster_issuer_name = "main-letsencrypt"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "cluster_environments" {
  for_each = toset(var.cluster_environments)
  source   = "./environment"

  environment_name  = each.key
  registry_server   = var.registry_server
  registry_username = var.registry_username
  registry_password = var.registry_password
}

module "gitlab_agent" {
  source = "./gitlab-agent"

  gitlab_agent_imagetag   = var.gitlab_agent_imagetag
  gitlab_agent_token      = var.gitlab_agent_token
  gitlab_agent_kasAddress = var.gitlab_agent_kasAddress
}

module "cert_manager" {
  source = "./cert-manager"

  cluster_issuer_name   = local.cluster_issuer_name
  cert_manager_imagetag = var.cert_manager_imagetag
  cluster_issuer_email  = var.cluster_issuer_email
  cluster_issuer_server = var.cluster_issuer_server

}

module "nginx_controller" {
  source     = "./nginx-controller"
  depends_on = [module.cert_manager]
}