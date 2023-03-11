# For more info view:
# https://cert-manager.io/docs/installation/helm/
# Parameters
# https://artifacthub.io/packages/helm/cert-manager/cert-manager

resource "helm_release" "cert_manager" {
  name             = "main"
  namespace        = "cert-manager-ns"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name  = "version"
    value = var.cert_manager_imagetag
  }

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "global.leaderElection.namespace" #GKE Autopilot fix
    value = "cert-manager-ns"
  }

}

