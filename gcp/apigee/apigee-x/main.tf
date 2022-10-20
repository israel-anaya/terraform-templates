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

locals {
  apigee_name = "${var.apigee_name}-apigee"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

# module "kms-org-db" {
#   source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v16.0.0"
#   project_id = var.project_id
#   key_iam = {
#     org-db = {
#       "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
#     }
#   }
#   keyring = {
#     location = var.ax_region
#     name     = var.apigee_org_kms_keyring_name
#   }
#   keys = {
#     org-db = { rotation_period = var.org_key_rotation_period, labels = null }
#   }
# }

# module "kms-inst-disk" {
#   for_each   = var.apigee_instances
#   source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v16.0.0"
#   project_id = var.project_id
#   key_iam = {
#     inst-disk = {
#       "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
#     }
#   }
#   keyring = {
#     location = each.value.region
#     name     = "apigee-${each.value.name}"
#   }
#   keys = {
#     inst-disk = { rotation_period = var.instance_key_rotation_period, labels = null }
#   }
# }

module "apigee_networks" {
  source       = "./networks"
  project_id   = var.project_id
  region       = var.region
  apigee_name  = local.apigee_name
  peer_network = var.peer_network

}

module "apigee_organization" {
  source             = "./organization"
  project_id         = var.project_id
  analytics_region   = var.region
  runtime_type       = "CLOUD"
  billing_type       = var.billing_type
  authorized_network = module.apigee_networks.network
  #database_encryption_key = module.kms-org-db.key_ids["org-db"]
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
  depends_on = [
    google_project_service_identity.apigee_sa #,
    #module.kms-org-db.id
  ]
}

module "apigee_x_instance" {
  for_each            = var.apigee_instances
  source              = "./instance"
  apigee_org_id       = module.apigee_organization.org_id
  name                = each.value.name
  region              = each.value.region
  #ip_range            = each.value.ip_range
  apigee_environments = each.value.environments
  #disk_encryption_key = module.kms-inst-disk[each.key].key_ids["inst-disk"]
  depends_on = [
    google_project_service_identity.apigee_sa#,
    #module.kms-inst-disk.self_link
  ]
}

module "admin" {
  source = "../../vms/vm-admin"

  project_id      = var.project_id
  region          = var.region
  zone            = var.main_zone
  prefix_name     = local.apigee_name
  network_name    = module.apigee_networks.network.name
  subnetwork_name = module.apigee_networks.subnetwork.name
}