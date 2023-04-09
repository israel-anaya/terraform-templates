locals {
  namespace = "${var.environment_name}-ns"
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = local.namespace
  }
}