# ==============================================================================
# Módulo: vpc-network — Contrato de Entrada (modules/vpc-network/variables.tf)
# ==============================================================================
# BOAS PRÁTICAS DE MÓDULOS TERRAFORM:
# 1. Toda variável deve ter `type` explícito e `description` clara.
# 2. Variáveis críticas devem ter blocos `validation` (ex: validar se a máscara
#    CIDR informada é sintaticamente válida usando `can(cidrhost(...))`).

variable "project_id" {
  type        = string
  description = "ID do projeto Google Cloud onde a VPC, Sub-rede e Cloud NAT serão criados."
}

variable "vpc_name" {
  type        = string
  description = "Nome da VPC customizada a ser criada (padrão RFC 1035 do GCP: minúsculas, números e hífens)."

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.vpc_name))
    error_message = "vpc_name deve começar com letra minúscula, conter apenas [a-z0-9-] e ter no máximo 63 caracteres."
  }
}

variable "vpc_description" {
  type        = string
  description = "Descrição opcional da VPC. ATENÇÃO: alterar a descrição de uma VPC existente força sua recriação."
  default     = null
}

variable "routing_mode" {
  type        = string
  description = "Modo de roteamento dinâmico da VPC (REGIONAL ou GLOBAL)."
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "O routing_mode deve ser REGIONAL ou GLOBAL."
  }
}

variable "region" {
  type        = string
  description = "Região da sub-rede e do Cloud Router/NAT."
  default     = "us-central1"
}

variable "subnet_name" {
  type        = string
  description = "Nome da sub-rede regional."

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.subnet_name))
    error_message = "subnet_name deve começar com letra minúscula, conter apenas [a-z0-9-] e ter no máximo 63 caracteres."
  }
}

variable "subnet_description" {
  type        = string
  description = "Descrição opcional da sub-rede."
  default     = null
}

variable "subnet_cidr" {
  type        = string
  description = "Bloco IPv4 CIDR da sub-rede (ex: 10.7.0.0/24)."

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "O valor de subnet_cidr deve ser um endereço IPv4 em notação CIDR válida (ex: 10.7.0.0/24)."
  }
}

variable "private_ip_google_access" {
  type        = bool
  description = "Habilita Private Google Access na sub-rede para VMs sem IP externo."
  default     = true
}

variable "enable_cloud_nat" {
  type        = bool
  description = "Se true, provisiona automaticamente Cloud Router + Cloud NAT (SNAT) para saída segura à internet."
  default     = true
}

variable "router_name" {
  type        = string
  description = "Nome opcional para o Cloud Router (se vazio, deriva do nome da VPC)."
  default     = ""
}

variable "nat_name" {
  type        = string
  description = "Nome opcional para o Cloud NAT (se vazio, deriva do nome da VPC)."
  default     = ""
}

variable "router_description" {
  type        = string
  description = "Descrição opcional do Cloud Router."
  default     = null
}
