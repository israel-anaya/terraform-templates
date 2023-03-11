# For more info view:
# https://artifacthub.io/packages/helm/bitnami/grafana

locals {
  dns_name_preffix = "grafana-${join("", var.cluster_environments)}"
  dns_name = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
}

resource "helm_release" "grafana" {
  name             = "main"
  namespace        = "monitoring-ns"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "grafana"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "ingress.hostname"
     value = local.dns_name
  }

}

