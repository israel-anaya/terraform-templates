# For more info view:
# https://cert-manager.io/docs/installation/helm/
# Parameters
# https://artifacthub.io/packages/helm/cert-manager/cert-manager

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = var.namespace

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name  = "version"
    value = var.imagetag
  }

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "global.leaderElection.namespace" #GKE Autopilot fix
    value = var.namespace
  }

}

