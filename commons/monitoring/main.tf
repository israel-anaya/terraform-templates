module "prometheus" {
    source = "./prometheus"
    
    imagetag              = var.imagetag
    cluster_instance_name = var.cluster_instance_name
    cluster_environments  = var.cluster_environments
    cluster_dns_name      = var.cluster_dns_name
}

module "grafana" {
    source = "./grafana"
    
    imagetag              = var.imagetag
    cluster_instance_name = var.cluster_instance_name
    cluster_environments  = var.cluster_environments
    cluster_dns_name      = var.cluster_dns_name
}