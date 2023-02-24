provider "google" {
  project = var.project_id
  region  = var.region
}

module "cluster_environments" {
  for_each = toset(var.cluster_environments)
  source   = "./environment"

  environment_name  = "${var.cluster_instance_name}-${each.key}"
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

  cert_manager_imagetag = var.cert_manager_imagetag
}

module "nginx_controller" {
  source     = "./nginx-controller"

  depends_on = [module.cert_manager]
}