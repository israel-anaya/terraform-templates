

# output "instance_endpoints" {
#   description = "Map of instance name -> internal runtime endpoint IP address"
#   value = tomap({
#     for name, instance in module.apigee_x_instance : name => instance.endpoint
#   })
# }

# output "instance_service_attachments" {
#   description = "Map of instance region -> instance PSC service attachment"
#   value = tomap({
#     for name, instance in module.apigee_x_instance : instance.instance.location => instance.instance.service_attachment
#   })
# }

output "org_id" {
  description = "Apigee Organization ID"
  value       = module.apigee_organization.org_id
}

output "endpoints" {
  description = "Map of instance name -> internal runtime endpoint IP address"
  value = tomap({
    for name, instance in module.apigee_x_instance : name => instance.endpoint
  })
}

output "ports" {
  description = "Port number of the internal endpoint of the Apigee instance."
  value = tomap({
    for port, instance in module.apigee_x_instance : port => instance.port
  })

}
