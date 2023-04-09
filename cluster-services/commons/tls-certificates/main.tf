
module "main_cluster_issuer" {
  source = "./cluster-issuer"

  cluster_instance_name = var.cluster_instance_name
  cluster_dns_name      = var.cluster_dns_name
  cluster_issuer_email  = var.cluster_issuer_email
  cluster_issuer_server = var.cluster_issuer_server
}

module "environments_certificates" {
  for_each = toset(var.cluster_environments)
  source   = "./env-certificate"

  cluster_environment_name = each.key
  cluster_instance_name    = var.cluster_instance_name
  cluster_dns_name         = var.cluster_dns_name
  cluster_issuer_name      = module.main_cluster_issuer.cluster_issuer_name

  depends_on = [
    module.main_cluster_issuer
  ]
}

