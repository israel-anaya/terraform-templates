resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

module "jenkins" {
  source = "./jenkins-jenkins"

  namespace = var.namespace
  imagetag  = var.imagetag
  dns_name  = var.cicd_dns_name
}

module "sonarqube" {
  source = "./sonarqube"

  namespace = var.namespace
  imagetag  = var.imagetag
  dns_name  = var.sast_dns_name
}

module "nexus_repository" {
  source = "./nexus-repository"

  namespace = var.namespace
  imagetag  = var.imagetag
  dns_name  = var.repository_dns_name
}
