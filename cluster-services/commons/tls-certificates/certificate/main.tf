locals {
  certificate_name = "${var.certificate_name}-cert"
  namespace = "${var.certificate_name}-ns"
  secret_name = "${var.certificate_name}-tls"
}

resource "kubernetes_namespace" "certificate" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = local.certificate_name
      "namespace" = local.namespace
    }
    "spec" = {
      "secretName"  = local.secret_name
      "dnsNames" = [
        var.cluster_dns_name,
      ]
      "duration" = "2160h0m0s" # 90d
      "renewBefore" = "360h0m0s" # 15d
      #"isCA"     = false
      "issuerRef" = {
        "group" = "cert-manager.io"
        "kind"  = "ClusterIssuer"
        "name"  = var.cluster_issuer_name
      }
      "privateKey" = {
        "algorithm" = "RSA"
        "encoding"  = "PKCS1"
        "size"      = 2048
      }
      "subject" = {
        "organizations" = [
          "my_organization",
        ]
      }
      "usages" = [
        "server auth",
        "client auth",
      ]
    }
  }
  depends_on = [kubernetes_namespace.certificate]
}