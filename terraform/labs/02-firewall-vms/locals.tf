# ==============================================================================
# Valores Calculados / Locals (labs/02-firewall-vms/locals.tf)
# ==============================================================================

locals {
  student_suffix = format("aluno-%02d", var.student_id)

  vpc_name    = "vpc-redes-tf-${local.student_suffix}"
  subnet_name = "subnet-${var.region}-${local.student_suffix}"
  vm_name     = "vm-teste-${local.student_suffix}"

  subnet_cidr = "10.${var.student_id}.0.0/24"

  common_labels = {
    evento       = "e-info-facape"
    minicurso    = "redes-tf-gcp"
    participante = local.student_suffix
    gerenciado   = "terraform"
  }
}
