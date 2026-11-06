# ==============================================================================
# Configuração do Provider Google Cloud (hub-facilitador/providers.tf)
# ==============================================================================

provider "google" {
  project = var.hub_project_id
  region  = var.region
  zone    = var.zone
}
