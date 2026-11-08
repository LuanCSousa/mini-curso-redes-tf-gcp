# ==============================================================================
# Variáveis de Entrada (labs/05-boas-praticas-modules/variables.tf)
# ==============================================================================

variable "project_id" {
  type        = string
  description = "ID do projeto Google Cloud atribuído à sua bancada/grupo (ex: einfo-redes-grupo-01)."

  validation {
    condition     = length(trimspace(var.project_id)) >= 6 && var.project_id != "SEU_PROJECT_ID_AQUI"
    error_message = "Informe um project_id válido do Google Cloud no arquivo terraform.tfvars."
  }
}

variable "student_id" {
  type        = number
  description = "Número único do aluno na turma (1 a 40)."

  validation {
    condition     = var.student_id >= 1 && var.student_id <= 40 && floor(var.student_id) == var.student_id
    error_message = "O student_id deve ser um número inteiro entre 1 e 40."
  }
}

variable "hub_project_id" {
  type        = string
  description = "ID do Projeto Central (Hub) mantido pelo facilitador Luan Sousa."
  default     = "einfo-redes-hub-central"
}

variable "region" {
  type        = string
  description = "Região do Google Cloud."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zona onde a VM privada de testes está provisionada."
  default     = "us-central1-a"
}
