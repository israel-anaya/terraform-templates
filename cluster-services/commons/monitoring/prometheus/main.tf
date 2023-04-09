# For more info view:
# https://artifacthub.io/packages/helm/prometheus-community/prometheus

locals {
  dns_name_preffix = "prometheus-${join("", var.cluster_environments)}"
  dns_name = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
}

resource "helm_release" "prometheus" {
  name             = "mainx"
  namespace        = "monitoring-ns"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  #values = [
  #  "${file("${path.module}/values.yaml")}"             
  #]

  #set {
  #   name  = "server.baseURL"
  #   value = local.dns_name
  #}

  #set {
  #   name  = "ingress.hosts"
  #   value = "{${local.dns_name}}"
  #}

  #set {
  #  name  = "prometheus-node-exporter.enabled"
  #  value = false
  #}
}

