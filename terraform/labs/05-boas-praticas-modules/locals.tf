# ==============================================================================
# Valores Calculados / Locals (labs/05-boas-praticas-modules/locals.tf)
# ==============================================================================
# Mesma convenção de nomes das Etapas 01 a 04 (necessário para a migração via moved.tf).

locals {
  student_suffix = format("aluno-%02d", var.student_id)

  vpc_name    = "vpc-redes-tf-${local.student_suffix}"
  subnet_name = "subnet-${var.region}-${local.student_suffix}"
  vm_name     = "vm-teste-${local.student_suffix}"
  router_name = "router-${var.region}-${local.student_suffix}"
  nat_name    = "nat-${var.region}-${local.student_suffix}"
  route_name  = "rota-internet-${local.student_suffix}"
  subnet_cidr = "10.${var.student_id}.0.0/24"

  # Alunos 01..20 -> vpc-hub-turma-a | Alunos 21..40 -> vpc-hub-turma-b
  is_turma_a   = var.student_id <= 20
  hub_vpc_name = local.is_turma_a ? "vpc-hub-turma-a" : "vpc-hub-turma-b"

  common_labels = {
    evento       = "e-info-facape"
    minicurso    = "redes-tf-gcp"
    participante = local.student_suffix
    gerenciado   = "terraform"
  }
}
