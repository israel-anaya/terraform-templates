locals {
  dns_name_preffix = "nifi-${join("", var.cluster_environments)}"
  dns_name = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
  secret_name = "${local.dns_name}-tls"
}

# resource "kubernetes_manifest" "certificate" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "Certificate"
#     "metadata" = {
#       "name"      = local.secret_name
#       "namespace" = var.namespace
#     }
#     "spec" = {
#       "secretName"  = local.secret_name
#       "dnsNames" = [
#         var.dns_name,
#       ]
#       "duration" = "2160h0m0s" # 90d
#       "renewBefore" = "360h0m0s" # 15d
#       #"isCA"     = false
#       "issuerRef" = {
#         "group" = "cert-manager.io"
#         "kind"  = "ClusterIssuer"
#         "name"  = "main-cert-manager-issuer"
#       }
#       "privateKey" = {
#         "algorithm" = "RSA"
#         "encoding"  = "PKCS1"
#         "size"      = 2048
#       }
#       "subject" = {
#         "organizations" = [
#           "my_organization",
#         ]
#       }
#       "usages" = [
#         "server auth",
#         "client auth",
#       ]
#     }
#   } 
# }

# For more info view:
# https://artifacthub.io/packages/helm/cetic/nifi
resource "helm_release" "nifi" {
  name             = "data-flow"
  namespace        = var.namespace

  repository = "https://cetic.github.io/helm-charts"
  chart      = "nifi"

  values = [
    "${file("${path.module}/values.yaml")}"
  ]

  set {
    name  = "ingress.hosts[0]"
    value = local.dns_name
  }

  set {
    name  = "properties.webProxyHost"
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
  # depends_on = [
  #   kubernetes_manifest.certificate
  # ]
}

