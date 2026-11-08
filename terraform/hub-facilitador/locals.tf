# ==============================================================================
# Valores Calculados do Hub Central (hub-facilitador/locals.tf)
# ==============================================================================

locals {
  # Configuração das 2 VPCs de Hub (VPC Sharding para suportar até 40 alunos
  # respeitando o limite do GCP de 25 VPC Peerings por VPC):
  hubs = {
    turma_a = {
      vpc_name      = "vpc-hub-turma-a"
      subnet_name   = "subnet-hub-turma-a"
      subnet_cidr   = "10.0.1.0/24"
      collector_ip  = "10.0.1.10"
      vm_name       = "vm-coletora-turma-a"
      student_range = "Alunos 01 a 20"
    }
    turma_b = {
      vpc_name      = "vpc-hub-turma-b"
      subnet_name   = "subnet-hub-turma-b"
      subnet_cidr   = "10.0.2.0/24"
      collector_ip  = "10.0.2.10"
      vm_name       = "vm-coletora-turma-b"
      student_range = "Alunos 21 a 40"
    }
  }

  # URL do Mural no Cloud Run ("" se desativado). Referência direta ao recurso:
  # o grafo do Terraform cria o Mural antes das VMs coletoras.
  mural_url = var.enable_mural ? google_cloud_run_v2_service.mural[0].uri : ""

  common_labels = {
    evento     = "e-info-facape"
    minicurso  = "redes-tf-gcp"
    componente = "hub-facilitador"
    gerenciado = "terraform"
  }
}
