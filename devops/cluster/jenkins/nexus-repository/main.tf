# For more info view:
# https://artifacthub.io/packages/helm/sonatype/nexus-repository-manager


resource "helm_release" "nexus-repository" {
  name             = "repository"
  namespace        = "cicd-ns"
  create_namespace = true

  repository = "https://sonatype.github.io/helm3-charts"
  chart      = "nexus-repository-manager"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "route.path"
     value = var.dns_name
  }

  #set {
  #   name  = "ingress.tls.secretName"
  #   value = "${var.dns_name}-tls"
  #}

  set {
     name  = "ingress.hostRepo"
     value = var.dns_name
  }

}

