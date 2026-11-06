# ==============================================================================
# Configuração do Provider Google Cloud (labs/02-firewall-vms/providers.tf)
# ==============================================================================

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
