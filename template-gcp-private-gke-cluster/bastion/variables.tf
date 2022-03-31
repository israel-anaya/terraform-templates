variable "cluster_name" {
  description = "Kubernetes cluster name"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the network in."
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "zone" {
  type        = string
  description = "The zone where the Bastion host is located in."
}

variable "network_name" {
  type        = string
  description = "The name of the network that should be used."
}

variable "subnetwork_name" {
  type        = string
  description = "The name of the subnet that should be used."
}