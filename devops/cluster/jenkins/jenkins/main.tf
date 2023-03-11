# For more info view:
# https://artifacthub.io/packages/helm/jenkinsci/jenkins


resource "helm_release" "jenkins" {
  name             = "cicd"
  namespace        = "cicd-ns"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "jenkins"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "ingress.hostname"
     value = var.dns_name
  }

  set {
     name  = "jenkinsHost"
     value = var.dns_name
  }

}

