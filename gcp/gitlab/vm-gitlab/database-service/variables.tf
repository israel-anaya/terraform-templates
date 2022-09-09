variable "environment" {
  description = "Environment name"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the network in."
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "network" {
  description = "The network that should be used."
}

variable "subnetwork" {
  description = "The subnetwork that should be used."
}

variable "tier" {
  type = string
}