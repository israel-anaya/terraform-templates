variable "cluster_instance_name" {
  type        = string
  description = "Cluster instance name"
}

variable "cluster_environments" {
  type        = list(string)
  description = "List of Environment Names."
}

variable "cluster_ingress_ip" {
  type        = string
}

variable "container_registry_server" {
}

variable "container_registry_username" {
}

variable "container_registry_password" {
}

variable "gitlab_agent_imagetag" {
}

variable "gitlab_agent_token" {
}

variable "gitlab_agent_kasAddress" {
}

variable "cert_manager_imagetag" {
}