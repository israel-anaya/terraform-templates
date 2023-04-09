locals {
  service_account_name       = "${var.cluster_service_account_id}-sa"
  service_account_token_name = "${var.cluster_service_account_id}-token"
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = local.service_account_name
    namespace = var.namespace
  }
}


resource "kubernetes_secret" "vault_token" {
  metadata {
    name      = local.service_account_token_name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.service_account_name
    }
  }
  
  type = "kubernetes.io/service-account-token"
}



