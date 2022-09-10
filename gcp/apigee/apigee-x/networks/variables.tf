variable "apigee_name" {
  description = "Apigee Core Name"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the network in"
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "peer_network" {
  description = "Resource link of the peer network."
  type        = string
}
