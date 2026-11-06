# ==============================================================================
# Variáveis de Entrada (pre-material/foundation-check/variables.tf)
# ==============================================================================

variable "project_id" {
  type        = string
  description = "ID do projeto Google Cloud atribuído ao seu grupo/bancada no minicurso (ex: einfo-redes-grupo-01)."

  validation {
    condition     = length(trimspace(var.project_id)) >= 6 && var.project_id != "SEU_PROJECT_ID_AQUI"
    error_message = "Informe um project_id válido do Google Cloud no seu arquivo terraform.tfvars."
  }
}

variable "student_id" {
  type        = number
  description = "Seu número único de participante na turma (de 1 a 40), utilizado para definir seu CIDR sem conflito."

  validation {
    condition     = var.student_id >= 1 && var.student_id <= 40 && floor(var.student_id) == var.student_id
    error_message = "O student_id deve ser um número inteiro entre 1 e 40."
  }
}

variable "student_name" {
  type        = string
  description = "Seu nome e sobrenome para identificação no Cartão de Foundation e no Mural do curso."

  validation {
    condition     = length(trimspace(var.student_name)) >= 3 && var.student_name != "Seu Nome Completo"
    error_message = "Preencha a variável student_name com seu nome real no arquivo terraform.tfvars."
  }
}

variable "region" {
  type        = string
  description = "Região padrão do Google Cloud utilizada nos laboratórios do minicurso."
  default     = "us-central1"
}
