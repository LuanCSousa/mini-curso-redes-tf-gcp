# ==============================================================================
# Configuração do Provider Google Cloud (labs/01-vpc-subnets/providers.tf)
# ==============================================================================
# O bloco provider conecta o Terraform às APIs do Google Cloud utilizando as
# credenciais geradas pelo comando: gcloud auth application-default login

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
