# ==============================================================================
# Versões do Terraform e Providers (labs/04-vpc-peering-hub/versions.tf)
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
