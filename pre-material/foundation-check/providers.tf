# ==============================================================================
# Configuração do Provider Google Cloud (pre-material/foundation-check/providers.tf)
# ==============================================================================
# O provider utiliza automaticamente as credenciais configuradas via:
# gcloud auth application-default login

provider "google" {
  project = var.project_id
  region  = var.region
}
