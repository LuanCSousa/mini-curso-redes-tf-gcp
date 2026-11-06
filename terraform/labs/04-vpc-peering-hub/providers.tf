# ==============================================================================
# Configuração do Provider Google Cloud (labs/04-vpc-peering-hub/providers.tf)
# ==============================================================================

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
