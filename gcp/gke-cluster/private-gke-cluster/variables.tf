variable "instance_name" {
  type        = string
  description = "Cluster instance name"
}

variable "project_id" {
  type        = string
  description = "The ID of the project to create resources in"
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "main_zone" {
  type        = string
  description = "The zone primary to use"
}

variable "cluster_node_zones" {
  type        = list(string)
  description = "The zones where Kubernetes cluster worker nodes should be located"
}

variable "machine_type" {
  type        = string
  description = "Instance type"
}

variable "node_count" {
  type        = number
  description = "Nodes by zone"
}
#variable "service_account" {
#  type = string
#  description = "The GCP service account"
#}
