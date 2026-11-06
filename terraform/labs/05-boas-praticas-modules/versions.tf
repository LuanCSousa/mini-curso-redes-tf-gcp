# ==============================================================================
# Versões do Terraform e Providers (labs/05-boas-praticas-modules/versions.tf)
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
