# ==============================================================================
# Módulo: vpc-peering — Contrato de Entrada (modules/vpc-peering/variables.tf)
# ==============================================================================

variable "peering_name" {
  type        = string
  description = "Nome do vínculo de VPC Network Peering."
}

variable "local_vpc_self_link" {
  type        = string
  description = "Self-link da VPC local (Spoke)."
}

variable "peer_project_id" {
  type        = string
  description = "ID do projeto Google Cloud onde reside a VPC remota (Hub)."
}

variable "peer_vpc_name" {
  type        = string
  description = "Nome da VPC remota (Hub) com a qual faremos Peering."
}

variable "export_custom_routes" {
  type        = bool
  description = "Define se rotas customizadas locais devem ser exportadas para o peer."
  default     = false
}

variable "import_custom_routes" {
  type        = bool
  description = "Define se rotas customizadas remotas devem ser importadas do peer."
  default     = false
}
