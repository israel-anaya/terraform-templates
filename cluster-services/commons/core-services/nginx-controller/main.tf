# For more info view:
# https://kubernetes.github.io/ingress-nginx/deploy/

# Values 
# https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml

locals {
  prefix_file = lower(var.cluster_type)
  values_file = "${local.prefix_file}-values.yaml"
}

data "template_file" "values" {
  template = "${file("${path.module}/${local.values_file}")}"
  #vars = {
  #  consul_address = "${aws_instance.consul.private_ip}"
  #}
}

resource "helm_release" "nginx_controller" {
  name             = "ingress-nginx"
  namespace        = var.namespace

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [
    data.template_file.values.rendered
  ]

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_ip
  } 


}