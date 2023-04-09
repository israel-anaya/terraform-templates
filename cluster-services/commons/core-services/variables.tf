variable "namespace" {
  type    = string
  default = "core-services-ns"
}

variable "cluster_type" {
  type        = string
  validation {
    condition = anytrue([
      var.cluster_type == "local",
      var.cluster_type == "GKE",
      var.cluster_type == "EKS",
      var.cluster_type == "AKS"
    ])
    error_message = "Cluster type must be local, GKE, EKS or AKS."
  }
}

variable "cluster_instance_name" {
  type        = string
  description = "Cluster instance name"
}

variable "cluster_environments" {
  type        = list(string)
  description = "List of Environment Names."
}

variable "cluster_dns_name" {
  type        = string
}

variable "cluster_ingress_ip" {
  type        = string
}

variable "cluster_vault_service_account_name" {
  default = "cluster-vault"
}