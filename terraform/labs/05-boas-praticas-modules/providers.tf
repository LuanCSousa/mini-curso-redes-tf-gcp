# ==============================================================================
# Configuração do Provider Google Cloud (labs/05-boas-praticas-modules/providers.tf)
# ==============================================================================

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
