# ==============================================================================
# Módulo: firewall-rules — Contrato de Entrada (modules/firewall-rules/variables.tf)
# ==============================================================================

variable "project_id" {
  type        = string
  description = "ID do projeto Google Cloud onde as regras de firewall serão criadas."
}

variable "vpc_id" {
  type        = string
  description = "ID ou self_link da VPC à qual as regras de firewall pertencem."
}

variable "name_suffix" {
  type        = string
  description = "Sufixo único para nomear as regras de firewall (ex: aluno-07)."

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]{0,30}[a-z0-9])?$", var.name_suffix))
    error_message = "name_suffix deve conter apenas [a-z0-9-] (ex: aluno-07)."
  }
}

variable "internal_source_ranges" {
  type        = list(string)
  description = "Lista de faixas CIDR internas autorizadas a enviar ICMP (ping) para as VMs."

  validation {
    condition     = length(var.internal_source_ranges) > 0 && alltrue([for c in var.internal_source_ranges : can(cidrhost(c, 0))])
    error_message = "internal_source_ranges deve ter ao menos 1 CIDR IPv4 válido (ex: 10.7.0.0/24)."
  }
}

variable "enable_iap_ssh" {
  type        = bool
  description = "Habilita a regra de entrada SSH (TCP 22) via Google Cloud IAP (35.235.240.0/20)."
  default     = true
}

variable "iap_target_tags" {
  type        = list(string)
  description = "Network Tags das VMs que receberão permissão de SSH via Cloud IAP."
  default     = ["ssh-iap"]

  validation {
    condition     = length(var.iap_target_tags) > 0
    error_message = "Informe ao menos uma network tag; sem tags a regra valeria para TODAS as VMs da VPC."
  }
}
