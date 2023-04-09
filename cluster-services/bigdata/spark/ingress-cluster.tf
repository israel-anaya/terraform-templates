locals {
  master_dns_name_preffix = "spark-master-${join("", var.cluster_environments)}"
  master_dns_name = "${local.master_dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
  master_secret_name = "${local.master_dns_name}-tls"
}

resource "kubernetes_ingress_v1" "cluster_port" {
  wait_for_load_balancer = true
  metadata {
    name      = "data-engine-spark-master-ingress"
    namespace = var.namespace

    annotations = {
      "cert-manager.io/cluster-issuer" = "main-cert-manager-issuer"
      "nginx.ingress.kubernetes.io/configuration-snippet" = "| proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection \"upgrade\"; "
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.master_dns_name
      http {
        path {
          path = "/"
          backend {
            service {
              name = "data-engine-spark-master-svc"
              port {
                number = 7077
              }
            }
          }
        }
      }
    }
  }
}
