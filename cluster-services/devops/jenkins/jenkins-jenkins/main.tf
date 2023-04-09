locals {
  secret_name = "${var.dns_name}-tls"
}

# For more info view:
# https://artifacthub.io/packages/helm/jenkinsci/jenkins
resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = var.namespace

  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  values = [
    "${file("${path.module}/values.yaml")}"             
  ]

  set {
     name  = "controller.jenkinsUrl"
     value = var.dns_name
  }  

  set {
     name  = "ingress.hostname"
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


}

