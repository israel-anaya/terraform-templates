# For more info view:
# https://kubernetes.github.io/ingress-nginx/deploy/

resource "helm_release" "nginx_controller" {
  name             = "main"
  namespace        = "nginx-controller-ns"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  #values = [
  #  "${file("nginx-values.yaml")}"
  #]

  #  set {
  #    name  = "controller.service.loadBalancerIP"
  #    value = local.ingress_ip
  #  } 


}