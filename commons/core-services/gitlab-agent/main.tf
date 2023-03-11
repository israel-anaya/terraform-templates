# For more info view:
# https://gitlab.com/gitlab-org/charts/gitlab-agent

resource "helm_release" "gitlab_agent" {
  name             = "main"
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
    value = var.gitlab_agent_kasAddress
  }

}