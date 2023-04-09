locals {
  cluster_issuer_name = "main-cert-manager-issuer"
}

resource "kubernetes_manifest" "cluster_issuer" {
  count = var.cluster_dns_name == "local" ? 0 : 1
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

resource "kubernetes_manifest" "local_cluster_issuer" {
  count = var.cluster_dns_name == "local" ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = local.cluster_issuer_name
    }
    "spec" = {
      "selfSigned" = {
      }
    }
  }
}