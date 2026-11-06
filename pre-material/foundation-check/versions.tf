# ==============================================================================
# Versões do Terraform e Providers (pre-material/foundation-check/versions.tf)
# ==============================================================================
# Define a versão mínima do Terraform (>= 1.5.0) e o provider oficial do
# Google Cloud (hashicorp/google).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
