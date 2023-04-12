resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

module "cluster_environments" {
  for_each = toset(var.cluster_environments)
  source   = "./environment"

  environment_name = "${var.cluster_instance_name}-${each.key}"
}

module "cert_manager" {
  source = "./cert-manager"

  imagetag  = ""
  namespace = var.namespace
}

module "nginx_controller" {
  source = "./nginx-controller"

  imagetag     = ""
  namespace    = var.namespace
  cluster_type = var.cluster_type
  ingress_ip   = var.cluster_ingress_ip
  depends_on   = [module.cert_manager]
}

# module "secure_store" {
#   source = "./vault"

#   imagetag                   = ""
#   namespace                  = var.namespace
#   cluster_type               = var.cluster_type
#   cluster_instance_name      = var.cluster_instance_name
#   cluster_environments       = var.cluster_environments
#   cluster_dns_name           = var.cluster_dns_name
#   cluster_service_account_id = var.cluster_vault_service_account_name

#   depends_on = [
#     module.cert_manager,
#     module.nginx_controller
#   ]
# }





# resource "null_resource" "unseal_secure_store" {

#   #provisioner "local-exec" {
#   #  command = "jq -r \".unseal_keys_b64[0]\" ${local.tokenfile}"
#   #}

#   provisioner "local-exec" {
#     command = "kubectl -n ${local.namespace} exec -it main-vault-0 -- vault operator unseal | jq -r \".unseal_keys_b64[0]\" ${local.tokenfile}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl -n ${local.namespace} exec -it main-vault-0 -- vault operator unseal | jq -r \".unseal_keys_b64[1]\" ${local.tokenfile}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl -n ${local.namespace} exec -it main-vault-0 -- vault operator unseal | jq -r \".unseal_keys_b64[2]\" ${local.tokenfile}"
#   }

#   depends_on = [
#     null_resource.init_secure_store
#   ]
# }
