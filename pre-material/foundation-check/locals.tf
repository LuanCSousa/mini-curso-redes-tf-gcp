# ==============================================================================
# Valores Calculados / Locals (pre-material/foundation-check/locals.tf)
# ==============================================================================
# Aqui calculamos automaticamente sua faixa de IPs exclusiva e para qual VPC
# do Projeto Central (Hub) sua rede irá apontar durante o VPC Peering.

locals {
  # Formata o ID com 2 dígitos (ex: 7 -> "aluno-07")
  student_suffix = format("aluno-%02d", var.student_id)

  # Nomenclatura padronizada que usaremos no Live Coding
  vpc_name    = "vpc-redes-tf-${local.student_suffix}"
  subnet_name = "subnet-${var.region}-${local.student_suffix}"

  # Bloco CIDR exclusivo do aluno (ex: Aluno 07 -> 10.7.0.0/24)
  subnet_cidr = "10.${var.student_id}.0.0/24"
  gateway_ip  = "10.${var.student_id}.0.1"

  # Divisão automática das VPCs do Hub para respeitar o limite de 25 Peerings/VPC do GCP:
  # - Alunos 01 a 20 conectam na vpc-hub-turma-a (10.0.1.0/24 -> VM Alvo: 10.0.1.10)
  # - Alunos 21 a 40 conectam na vpc-hub-turma-b (10.0.2.0/24 -> VM Alvo: 10.0.2.10)
  is_turma_a    = var.student_id <= 20
  hub_vpc_name  = local.is_turma_a ? "vpc-hub-turma-a" : "vpc-hub-turma-b"
  hub_subnet    = local.is_turma_a ? "10.0.1.0/24" : "10.0.2.0/24"
  hub_target_ip = local.is_turma_a ? "10.0.1.10" : "10.0.2.10"
}
