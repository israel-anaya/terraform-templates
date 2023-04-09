# For more info view:
# https://artifacthub.io/packages/helm/bitnami/kafka


locals {
  dns_name_preffix = "im-${join("", var.cluster_environments)}"
  dns_name         = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
}

resource "helm_release" "kafka" {
  name             = "main"
  namespace        = "message-broker-ns"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"

  values = [
    "${file("${path.module}/values.yaml")}"
  ]

  # set {
  #    name  = "ingress.hostname"
  #    value = local.dns_name
  # }

}

module "akhq" {
  count  = var.enabled_ui == true ? 1 : 0
  source = "./akhq"

  imagetag              = ""
  cluster_instance_name = var.cluster_instance_name
  cluster_environments  = var.cluster_environments
  cluster_dns_name      = var.cluster_dns_name

  depends_on = [
    helm_release.kafka
  ]
}
