resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

module "object_storage" {
  source = "./minio"

  namespace             = var.namespace
  imagetag              = var.imagetag
  cluster_instance_name = var.cluster_instance_name
  cluster_environments  = var.cluster_environments
  cluster_dns_name      = var.cluster_dns_name
  depends_on = [
    kubernetes_namespace.main
  ]
}

module "data_engine" {
  source = "./spark"

  namespace             = var.namespace
  imagetag              = var.imagetag
  cluster_instance_name = var.cluster_instance_name
  cluster_environments  = var.cluster_environments
  cluster_dns_name      = var.cluster_dns_name
  depends_on = [
    kubernetes_namespace.main
  ]
}


module "data_flow" {
  source = "./nifi"

  namespace             = var.namespace
  imagetag              = var.imagetag
  cluster_instance_name = var.cluster_instance_name
  cluster_environments  = var.cluster_environments
  cluster_dns_name      = var.cluster_dns_name
  depends_on = [
    kubernetes_namespace.main,
    module.data_engine
  ]
}
