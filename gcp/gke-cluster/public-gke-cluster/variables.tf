variable "environment" {
  description = "Environment name"
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "node_count" {
  default     = 1
  description = "Number of gke nodes by zone"
}

variable "machine_type" {
  default     = "e2-micro"
  description = "Machine type"
}
