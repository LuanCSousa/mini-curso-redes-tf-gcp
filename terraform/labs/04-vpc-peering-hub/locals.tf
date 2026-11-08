# ==============================================================================
# Valores Calculados / Locals (labs/04-vpc-peering-hub/locals.tf)
# ==============================================================================

locals {
  student_suffix = format("aluno-%02d", var.student_id)

  vpc_name    = "vpc-redes-tf-${local.student_suffix}"
  subnet_name = "subnet-${var.region}-${local.student_suffix}"
  vm_name     = "vm-teste-${local.student_suffix}"
  router_name = "router-${var.region}-${local.student_suffix}"
  nat_name    = "nat-${var.region}-${local.student_suffix}"
  route_name  = "rota-internet-${local.student_suffix}"

  subnet_cidr = "10.${var.student_id}.0.0/24"

  # ----------------------------------------------------------------------------
  # ENGENHARIA DE COTAS GCP (VPC SHARDING PARA ATÉ 40 ALUNOS):
  # O Google Cloud impõe um limite rígido de 25 VPC Peerings ativos por VPC.
  # Para suportar até 40 alunos simultâneos sem estourar a cota:
  # - Alunos 01 a 20 conectam na `vpc-hub-turma-a` (10.0.1.0/24 -> VM 10.0.1.10)
  # - Alunos 21 a 40 conectam na `vpc-hub-turma-b` (10.0.2.0/24 -> VM 10.0.2.10)
  # ----------------------------------------------------------------------------
  is_turma_a      = var.student_id <= 20
  hub_vpc_name    = local.is_turma_a ? "vpc-hub-turma-a" : "vpc-hub-turma-b"
  hub_subnet_cidr = local.is_turma_a ? "10.0.1.0/24" : "10.0.2.0/24"
  hub_target_ip   = local.is_turma_a ? "10.0.1.10" : "10.0.2.10"

  # URI completa (Self-Link) da VPC Central do Facilitador:
  hub_vpc_self_link = "projects/${var.hub_project_id}/global/networks/${local.hub_vpc_name}"

  common_labels = {
    evento       = "e-info-facape"
    minicurso    = "redes-tf-gcp"
    participante = local.student_suffix
    gerenciado   = "terraform"
  }
}
