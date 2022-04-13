terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.13.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.13.0"
    }
  }

  required_version = ">= 0.14"
}
