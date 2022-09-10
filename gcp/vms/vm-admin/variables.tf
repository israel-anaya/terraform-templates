variable "prefix_name" {
  description = "Prefix name for the instance."
}

variable "project_id" {
  type        = string
  description = "The project ID that should be used."
}

variable "region" {
  type        = string
  description = "The region that should be used."
}

variable "zone" {
  type        = string
  description = "The zone where the Admin host is located in."
}

variable "network_name" {
  type        = string
  description = "The name of the network that should be used."
}

variable "subnetwork_name" {
  type        = string
  description = "The name of the subnet that should be used."
}