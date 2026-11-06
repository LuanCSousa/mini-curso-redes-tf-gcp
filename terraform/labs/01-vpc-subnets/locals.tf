# ==============================================================================
# Valores Calculados / Locals (labs/01-vpc-subnets/locals.tf)
# ==============================================================================
# O bloco locals evita repetição de interpolações e garante que todos os alunos
# do mesmo projeto GCP tenham nomes de recursos e faixas CIDR 100% isolados.

locals {
  # Formata o número do aluno sempre com 2 dígitos (ex: 7 -> "aluno-07")
  student_suffix = format("aluno-%02d", var.student_id)

  # Nomenclatura padronizada de recursos: <tipo>-<contexto>-aluno-XX
  vpc_name    = "vpc-redes-tf-${local.student_suffix}"
  subnet_name = "subnet-${var.region}-${local.student_suffix}"

  # Endereçamento IPv4 (RFC 1918 - Classe A Privada):
  # Cada aluno recebe um bloco /24 exclusivo (256 endereços totais, 252 utilizáveis no GCP).
  # Exemplo para student_id = 7 -> "10.7.0.0/24"
  subnet_cidr = "10.${var.student_id}.0.0/24"

  # Labels (etiquetas) padrão para organização e governança de custos (FinOps)
  common_labels = {
    evento      = "e-info-facape"
    minicurso   = "redes-tf-gcp"
    participante = local.student_suffix
    gerenciado  = "terraform"
  }
}
