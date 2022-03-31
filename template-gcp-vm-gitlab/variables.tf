variable "environment" {
  description = "Environment name"
}

variable "project_id" {
  type        = string
  description = "The ID of the project to create resources in"
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "main_zone" {
  type        = string
  description = "The zone primary to use"
}

variable "database_tier" {
  type = string
}

variable "bastion_machine_type" {
  type = string
}

variable "gitlab_machine_type" {
  type = string
}

variable "workers_machine_type" {
  type = string
}

variable "sonarqube_machine_type" {
  type = string
}
