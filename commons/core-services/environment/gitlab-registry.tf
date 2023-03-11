resource "kubernetes_secret" "gitlab_registry" {
  metadata {
    name      = "gitlab-registry"
    namespace = local.namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.container_registry_server}" = {
          auth = "${base64encode("${var.container_registry_username}:${var.container_registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [
    kubernetes_namespace.main,
  ]
}