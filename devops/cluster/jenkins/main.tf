module "jenkins" {
    source = "./jenkins"
    
    imagetag      = var.imagetag
    dns_name      = var.cicd_dns_name
}

# module "sonarqube" {
#     source = "./sonarqube"
    
#     imagetag      = var.imagetag
#     dns_name      = var.sast_dns_name
# }

# module "nexus_repository" {
#     source = "./nexus-repository"
    
#     imagetag      = var.imagetag
#     dns_name      = var.repository_dns_name
# }