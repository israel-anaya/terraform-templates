variable "project_id" {
  type        = string
  description = "The ID of the project to create resources in"
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "cluster_environments" {
  description = "List of Environment Names."
}

variable "registry_server" {
}

variable "registry_username" {
}

variable "registry_password" {
}

variable "gitlab_agent_imagetag" {
}

variable "gitlab_agent_token" {
}

variable "gitlab_agent_kasAddress" {
}

variable "cert_manager_imagetag" {
}

variable "cluster_issuer_server" {
}

variable "cluster_issuer_email" {
}