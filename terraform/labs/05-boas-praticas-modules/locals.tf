# ==============================================================================
# Valores Calculados / Locals (labs/05-boas-praticas-modules/locals.tf)
# ==============================================================================

locals {
  student_suffix = format("aluno-%02d", var.student_id)

  vpc_name    = "vpc-redes-tf-${local.student_suffix}"
  subnet_name = "subnet-${var.region}-${local.student_suffix}"
  vm_name     = "vm-teste-${local.student_suffix}"
  subnet_cidr = "10.${var.student_id}.0.0/24"

  is_turma_a   = var.student_id <= 20
  hub_vpc_name = local.is_turma_a ? "vpc-hub-turma-a" : "vpc-hub-turma-b"

  common_labels = {
    evento       = "e-info-facape"
    minicurso    = "redes-tf-gcp"
    participante = local.student_suffix
    arquitetura  = "modular"
  }
}
