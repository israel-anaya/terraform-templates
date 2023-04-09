
locals {
  secret_name = "${var.dns_name}-tls"
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "repository-cert"
      "namespace" = var.namespace
    }
    "spec" = {
      "secretName"  = local.secret_name
      "dnsNames" = [
        var.dns_name,
      ]
      "duration" = "2160h0m0s" # 90d
      "renewBefore" = "360h0m0s" # 15d
      #"isCA"     = false
      "issuerRef" = {
        "group" = "cert-manager.io"
        "kind"  = "ClusterIssuer"
        "name"  = "main-cert-manager-issuer"
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
  
}

# For more info view:
# https://artifacthub.io/packages/helm/sonatype/nexus-repository-manager

resource "helm_release" "nexus-repository" {
  name             = "nexus-repository-manager"
  namespace        = var.namespace


  repository = "https://sonatype.github.io/helm3-charts"
  chart      = "nexus-repository-manager"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "route.path"
     value = var.dns_name
  }

  set {
     name  = "ingress.hostRepo"
     value = var.dns_name
  }

  set {
     name  = "ingress.tls[0].secretName"
     value = local.secret_name
  }

  set {
     name  = "ingress.tls[0].hosts[0]"
     value = var.dns_name
  }
  depends_on = [
    kubernetes_manifest.certificate
  ]
}

