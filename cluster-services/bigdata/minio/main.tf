locals {
  dns_name_preffix = "minio-${join("", var.cluster_environments)}"
  dns_name = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
  secret_name = "${local.dns_name}-tls"
}

# For more info view:
# https://artifacthub.io/packages/helm/bitnami/minio
resource "helm_release" "minio" {
  name             = "object-storage"
  namespace        = var.namespace

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "ingress.hostname"
     value = local.dns_name
  }  

}

