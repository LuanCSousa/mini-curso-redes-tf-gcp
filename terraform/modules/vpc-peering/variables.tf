# ==============================================================================
# Módulo: vpc-peering — Contrato de Entrada (modules/vpc-peering/variables.tf)
# ==============================================================================

variable "peering_name" {
  type        = string
  description = "Nome do vínculo de VPC Network Peering."

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.peering_name))
    error_message = "peering_name deve seguir o padrão RFC 1035 do GCP (ex: peer-aluno-07-to-hub)."
  }
}

variable "local_vpc_self_link" {
  type        = string
  description = "Self-link da VPC local (Spoke)."

  validation {
    condition     = can(regex("projects/[^/]+/global/networks/[^/]+$", var.local_vpc_self_link))
    error_message = "local_vpc_self_link deve ser um self-link/ID de VPC (.../projects/<p>/global/networks/<vpc>)."
  }
}

variable "peer_project_id" {
  type        = string
  description = "ID do projeto Google Cloud onde reside a VPC remota (Hub)."

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.peer_project_id))
    error_message = "peer_project_id deve ser um Project ID válido do GCP (6 a 30 caracteres, minúsculas, números e hífens)."
  }
}

variable "peer_vpc_name" {
  type        = string
  description = "Nome da VPC remota (Hub) com a qual faremos Peering."

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.peer_vpc_name))
    error_message = "peer_vpc_name deve ser um nome de VPC válido (ex: vpc-hub-turma-a)."
  }
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
