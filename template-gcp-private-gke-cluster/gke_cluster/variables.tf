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

variable "service_account_iam_roles" {
  type = list(string)

  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ]
  description = <<-EOF
  List of the default IAM roles to attach to the service account on the
  GKE Nodes.
  EOF
}

variable "service_account_custom_iam_roles" {
  type = list(string)
  default = []

  description = <<-EOF
  List of arbitrary additional IAM roles to attach to the service account on
  the GKE nodes.
  EOF
}