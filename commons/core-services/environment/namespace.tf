resource "kubernetes_namespace" "main" {
  metadata {
    name = local.namespace
  }
}