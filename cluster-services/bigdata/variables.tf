variable "namespace" {
  type    = string
  default = "devops-ns"
}

variable "imagetag" {
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
}


