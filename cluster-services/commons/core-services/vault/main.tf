locals {
  dns_name_preffix = "ss-${join("", var.cluster_environments)}"
  dns_name         = "${local.dns_name_preffix}.${var.cluster_instance_name}.${var.cluster_dns_name}"
  secret_name      = "${local.dns_name}-tls"
}

# For more info view:
# https://artifacthub.io/packages/helm/hashicorp/vault
resource "helm_release" "vault" {
  name      = "vault"
  namespace = var.namespace

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [
    "${file("${path.module}/values.yaml")}"
  ]

  set {
    name  = "server.ingress.hosts[0].host"
    value = local.dns_name
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = local.secret_name
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = local.dns_name
  }
}

locals {
  module_path   = abspath(path.root)
  tokenfile     = "${local.module_path}/ss-token.json"
  enabledfile   = "${local.module_path}/enable-vault.sh"
  enabledcafile = "${local.module_path}/enable-ca-vault.sh"
  https_proxy   = var.cluster_type == "local" ? "" : "localhost:8888"
}

resource "time_sleep" "wait_for_vault" {
  create_duration = var.cluster_type == "local" ? "0s" : "180s"

  depends_on = [
    helm_release.vault
  ]
}

resource "null_resource" "init_vault" {

  provisioner "local-exec" {
    command = "kubectl -n ${var.namespace} exec -i vault-0 -- vault operator init -format=json > ${local.tokenfile}"

    environment = {
      HTTPS_PROXY = local.https_proxy
    }
  }

  depends_on = [
    time_sleep.wait_for_vault
  ]
}


data "local_file" "tokenfile" {
  filename = local.tokenfile
  depends_on = [
    null_resource.init_vault,
  ]
}

resource "null_resource" "unseal_vault" {

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-EOF
      kubectl -n ${var.namespace} exec -i vault-0 -- vault operator unseal $FIRST_TOKEN
      kubectl -n ${var.namespace} exec -i vault-0 -- vault operator unseal $SECOND_TOKEN
      kubectl -n ${var.namespace} exec -i vault-0 -- vault operator unseal $THIRD_TOKEN
    EOF

    environment = {
      HTTPS_PROXY  = local.https_proxy
      FIRST_TOKEN  = jsondecode(data.local_file.tokenfile.content).unseal_keys_b64[0]
      SECOND_TOKEN = jsondecode(data.local_file.tokenfile.content).unseal_keys_b64[2]
      THIRD_TOKEN  = jsondecode(data.local_file.tokenfile.content).unseal_keys_b64[4]
    }

  }

  depends_on = [
    null_resource.init_vault,
    data.local_file.tokenfile
  ]
}

locals {
  common_name = "${var.cluster_instance_name}.${var.cluster_dns_name}"
  pki_role    = "${var.cluster_instance_name}-${var.cluster_dns_name}"
}


data "template_file" "enable_vault" {
  template = file("${path.module}/templates/enable-vault.sh")
  vars = {
    ROOT_TOKEN           = jsondecode(data.local_file.tokenfile.content).root_token
    COMMON_NAME          = local.common_name
    PKI_ROLE             = local.pki_role
    SERVICE_ACCOUNT_NAME = local.service_account_name
    NAMESPACE            = var.namespace
  }

  depends_on = [
    null_resource.init_vault,
    data.local_file.tokenfile,
    null_resource.unseal_vault
  ]
}

resource "local_file" "enable_vault" {

  content  = data.template_file.enable_vault.rendered
  filename = local.enabledfile

  depends_on = [
    null_resource.init_vault,
    null_resource.unseal_vault
  ]
}

resource "null_resource" "enable_vault" {

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-EOF
      kubectl -n ${var.namespace} cp ${local.enabledfile} vault-0:/tmp/enable.sh
      kubectl -n ${var.namespace} exec -i vault-0 -- sh /tmp/enable.sh
      kubectl -n ${var.namespace} exec -i vault-0 -- rm /tmp/enable.sh
    EOF

    environment = {
      HTTPS_PROXY = local.https_proxy
    }
  }

  depends_on = [
    null_resource.init_vault,
    null_resource.unseal_vault,
    local_file.enable_vault
  ]
}
















# resource "null_resource" "cleanup" {

#   triggers = {
#     invokes_me_everytime = uuid()
#     tokenfile            = local.tokenfile
#     enabledfile          = local.enabledfile
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm $FILE"

#     environment = {
#       FILE = self.triggers.tokenfile
#     }
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm $FILE"

#     environment = {
#       FILE = self.triggers.enabledfile
#     }
#   }
# }





# data "template_file" "enable_ca_vault" {
#   template = file("${path.module}/templates/enable-ca-vault.sh")
#   vars = {
#     ROOT_TOKEN           = jsondecode(data.local_file.tokenfile.content).root_token
#     COMMON_NAME          = local.common_name
#     PKI_ROLE             = local.pki_role
#   }

#   depends_on = [
#     null_resource.init_vault,
#     data.local_file.tokenfile,
#     null_resource.unseal_vault
#   ]
# }

# resource "local_file" "enable_ca_vault" {

#   content  = data.template_file.enable_ca_vault.rendered
#   filename = local.enabledcafile

#   depends_on = [
#     null_resource.init_vault,
#     null_resource.unseal_vault
#   ]
# }
