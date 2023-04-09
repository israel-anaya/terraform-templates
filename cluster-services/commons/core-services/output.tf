output "secure_store_service_dns_name" {
  value = module.secure_store.service_dns_name
}

output "cluster_namespaces" {
  value = [for item in module.cluster_environments : item.namespace]
}