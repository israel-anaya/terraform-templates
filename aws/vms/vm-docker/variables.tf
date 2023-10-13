variable "environment" {
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "The region to use"
}


variable "main_zone" {
  type        = string
  description = "The zone primary to use"
}

#variable "bastion_machine_type" {
#  type = string
#}

variable "machine_name" {
  type = string
}

variable "machine_type" {
  type = string
  default = "t2.micro"
}