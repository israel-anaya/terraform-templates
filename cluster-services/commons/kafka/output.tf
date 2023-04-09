output "service_dns_name" {
    value = local.dns_name
}

output "ui_service_dns_name" {
    value = var.enabled_ui == true ? module.akhq[0].service_dns_name : ""
}

