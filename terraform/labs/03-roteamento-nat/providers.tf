# ==============================================================================
# Configuração do Provider Google Cloud (labs/03-roteamento-nat/providers.tf)
# ==============================================================================

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
