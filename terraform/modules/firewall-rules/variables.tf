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
}

variable "internal_source_ranges" {
  type        = list(string)
  description = "Lista de faixas CIDR internas autorizadas a trocar ICMP (ping) e HTTP interno."
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
}
