# ==============================================================================
# Validação do Foundation no GCP (pre-material/foundation-check/main.tf)
# ==============================================================================

# 1. Consulta em tempo real a API do Compute Engine no seu projeto GCP.
# Se suas credenciais ADC (gcloud auth application-default login) ou permissões
# no projeto estiverem incorretas, o Terraform avisará imediatamente aqui!
data "google_compute_zones" "zonas_disponiveis" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

# 2. Registra no estado do Terraform (terraform.tfstate) o comprovante de que
# seu ambiente local/Cloud Shell e sua comunicação com a API do GCP funcionaram.
# Nota: Este recurso tem custo ZERO (US$ 0.00) na fatura do Google Cloud.
resource "terraform_data" "comprovante_foundation" {
  input = {
    student_id       = var.student_id
    student_code     = local.student_suffix
    student_name     = var.student_name
    project_id       = var.project_id
    region           = var.region
    detected_zones   = data.google_compute_zones.zonas_disponiveis.names
    planned_vpc_name = local.vpc_name
    planned_cidr     = local.subnet_cidr
    assigned_hub_vpc = local.hub_vpc_name
    assigned_hub_ip  = local.hub_target_ip
  }
}
