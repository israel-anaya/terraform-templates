variable "cluster_name" {
  description = "Kubernetes cluster name"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the GKE"
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "service_account" {
  type = string
}

variable "node_zones" {
  type        = list(string)
  description = "The zones where worker nodes are located"
}

variable "network" {
  description = "The VPC"
}

variable "subnetwork" {
  description = "The subnetwork"
}

variable "authorized_ipv4_cidr_block" {
  type        = string
  description = "The CIDR block where HTTPS access is allowed from"
  default     = null
}

variable "machine_type" {
  type        = string
  description = "Instance type"
}

variable "node_count" {
  type        = number
  description = "Nodes by zone"
}

