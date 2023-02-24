# Cert Issuer using Helm
resource "helm_release" "cluster_issuer" {
  name       = "main"
  repository = path.module
  chart      = "chart-cluster-issuer"
  namespace  = "cert-manager-ns"

  set {
    name  = "fullnameOverride"
    value = local.issuer_name
  }

  set {
    name  = "privateKeySecretRef"
    value = local.issuer_name
  }

  set {
    name  = "ingressClass"
    value = var.ingress_class
  }

  set {
    name  = "acmeEmail"
    value = var.cluster_issuer_email
  }

  set {
    name  = "acmeServer"
    value = var.cluster_issuer_server
  }