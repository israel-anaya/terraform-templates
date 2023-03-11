
module "cluster_environments" {
  for_each = toset(var.cluster_environments)
  source   = "./environment"

  environment_name  = "${var.cluster_instance_name}-${each.key}"
  container_registry_server   = var.container_registry_server
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password
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

  ingress_ip = var.cluster_ingress_ip
  depends_on = [module.cert_manager]
}