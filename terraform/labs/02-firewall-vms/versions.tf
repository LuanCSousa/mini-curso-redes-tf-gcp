# ==============================================================================
# Versões do Terraform e Providers (labs/02-firewall-vms/versions.tf)
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
