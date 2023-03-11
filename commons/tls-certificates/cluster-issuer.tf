resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = local.cluster_issuer_name
    }
    "spec" = {
      "acme" = {
        "email" = var.cluster_issuer_email
        "privateKeySecretRef" = {
          "name" = "${local.cluster_issuer_name}-key"
        }
        "server" = var.cluster_issuer_server
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}