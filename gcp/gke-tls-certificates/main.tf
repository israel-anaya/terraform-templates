locals {
  cluster_issuer_name = "main-cert-manager-issuer"
}

module "cluster_certificates" {
  for_each = toset(var.cluster_environments)
  source = "./certificate"

  cluster_environment_name  = each.key  
  cluster_instance_name = var.cluster_instance_name
  cluster_dns_name    = var.cluster_dns_name
  cluster_issuer_name = local.cluster_issuer_name

  depends_on = [kubernetes_manifest.cluster_issuer]
}


