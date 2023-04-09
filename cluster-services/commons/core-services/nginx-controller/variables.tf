variable "namespace" {
  type    = string
}

variable "imagetag" {
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

variable "ingress_ip" {
  type        = string
}
