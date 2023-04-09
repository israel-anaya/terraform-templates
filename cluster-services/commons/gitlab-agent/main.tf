locals {
  gitlab_container_registry = "${var.gitlab_host}:5050"
  gitlab_agent_kasAddress   = "wss://${var.gitlab_host}/-/kubernetes-agent/"
}

# For more info view:
# https://gitlab.com/gitlab-org/charts/gitlab-agent
resource "helm_release" "gitlab_agent" {
  name             = "gitlab-agent"
  namespace        = "gitlab-agent-ns"
  create_namespace = true

  repository = "https://charts.gitlab.io"
  chart      = "gitlab-agent"

  set {
    name  = "image.tag"
    value = var.gitlab_agent_imagetag
  }

  set {
    name  = "config.token"
    value = var.gitlab_agent_token
  }

  set {
    name  = "config.kasAddress"
    value = local.gitlab_agent_kasAddress
  }

}

# Container Registry secret by each namespace
resource "kubernetes_secret" "gitlab_container_registry" {
  for_each = toset(var.cluster_namespaces)

  metadata {
    name      = "gitlab-container-registry"
    namespace = each.key
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${local.gitlab_container_registry}" = {
          auth = "${base64encode("${var.container_registry_username}:${var.container_registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

}
