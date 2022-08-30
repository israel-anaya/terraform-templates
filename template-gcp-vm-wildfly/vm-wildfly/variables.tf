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

variable "zone" {
  type        = string
  description = "The zone where the instance host is located in."
}

variable "network" {
  description = "The network that should be used."
}

variable "subnetwork" {
  description = "The subnetwork that should be used."
}

variable "bastion_hostname" {
  description = "The Bastion hostname."
}

variable "service_account" {
  description = "Service account that should be used."
}

variable "machine_type" {
  type        = string
  description = "Instance type that should be used."
}