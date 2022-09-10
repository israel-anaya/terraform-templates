/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#variable "environment" {
#  description = "Environment name"
#}

variable "apigee_name" {
  description = "Apigee Core Name"
  type        = string
}

variable "project_id" {
  type        = string
  description = "The ID of the project to create resources (also used for the Apigee Organization) in"
}

variable "region" {
  type        = string
  description = "The region to use."
  # "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
}

variable "main_zone" {
  type        = string
  description = "The zone primary to use."
}

variable "billing_type" {
  description = "Billing type of the Apigee organization."
  type        = string
  default     = null
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    environments = list(string)
    hostnames    = list(string)
  }))
  default = {}
}

variable "apigee_environments" {
  description = "Apigee Environment Names."
  type        = list(string)
  default     = []
}

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL)."
  type = map(object({
    name         = string
    region       = string
    ip_range     = string
    environments = list(string)
  }))
  default = {}
}

variable "org_key_rotation_period" {
  description = "Rotaton period for the organization DB encryption key"
  type        = string
  default     = "2592000s"
}

variable "instance_key_rotation_period" {
  description = "Rotaton period for the instance disk encryption key"
  type        = string
  default     = "2592000s"
}

variable "apigee_org_kms_keyring_name" {
  description = "Name of the KMS Key Ring for Apigee Organization DB."
  type        = string
}

variable "peer_network" {
  description = "Resource link of the peer network."
  type        = string
}
