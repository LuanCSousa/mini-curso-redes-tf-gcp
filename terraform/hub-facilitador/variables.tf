# ==============================================================================
# Variáveis do Projeto Central / Hub (hub-facilitador/variables.tf)
# ==============================================================================

variable "hub_project_id" {
  type        = string
  description = "ID do Projeto Central (Hub) mantido pelo facilitador Luan Sousa."
  default     = "einfo-redes-hub-central"
}

variable "region" {
  type        = string
  description = "Região onde as sub-redes e VMs coletoras do Hub serão provisionadas."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zona onde as 2 VMs coletoras (e2-micro) serão provisionadas."
  default     = "us-central1-a"
}

variable "mural_cloud_run_url" {
  type        = string
  description = "URL opcional do serviço Cloud Run do Mural ao Vivo para onde as VMs coletoras encaminham os check-ins."
  default     = ""
}

variable "mural_service_name" {
  type        = string
  description = "Nome do serviço Cloud Run do Mural (usado na permissão run.invoker das VMs coletoras)."
  default     = "mural-redes-tf"
}

variable "active_student_peerings" {
  type = map(object({
    student_id         = number
    student_project_id = string
  }))
  description = "Mapa opcional de alunos para fechamento declarativo de VPC Peering via Terraform (deixe vazio se usar o script auto-accept-peerings.sh)."
  default     = {}
}
