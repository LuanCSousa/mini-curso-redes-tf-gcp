# ==============================================================================
# Versões do Terraform e Providers (labs/01-vpc-subnets/versions.tf)
# ==============================================================================
# Todo projeto Terraform profissional inicia travando a versão mínima do binário
# do Terraform e dos provedores de nuvem para evitar quebras por atualizações.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
