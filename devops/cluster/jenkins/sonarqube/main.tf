# For more info view:
# https://artifacthub.io/packages/helm/bitnami/sonarqube


resource "helm_release" "sonarqube" {
  name             = "sast"
  namespace        = "cicd-ns"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "sonarqube"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "ingress.hostname"
     value = var.dns_name
  }

}

