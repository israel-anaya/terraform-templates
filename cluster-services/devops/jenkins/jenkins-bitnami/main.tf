# For more info view:
# https://artifacthub.io/packages/helm/bitnami/jenkins


resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = var.namespace

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "jenkins"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "ingress.hostname"
     value = var.dns_name
  }

  #set {
  #   name  = "jenkinsHost"
  #   value = var.dns_name
  #}

}

