resource "kubernetes_persistent_volume_claim" "cache" {
  metadata {
    name      = "jenkins-cache-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}
