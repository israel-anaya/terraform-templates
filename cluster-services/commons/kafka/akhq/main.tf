# For more info view:
# https://artifacthub.io/packages/helm/akhq/akhq


locals {
  dns_name_preffix = "mb-${join("", var.cluster_environments)}"
  dns_name = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
  secret_name = "${local.dns_name}-tls"
}

resource "helm_release" "akhq" {
  name             = "ui"
  namespace        = "message-broker-ns"

  repository = "https://akhq.io/"
  chart      = "akhq"

  values = [
    "${file("${path.module}/values.yaml")}"
  ]

  set {
    name  = "ingress.hosts[0]"
    value = local.dns_name
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = local.secret_name
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = local.dns_name
  }

}

