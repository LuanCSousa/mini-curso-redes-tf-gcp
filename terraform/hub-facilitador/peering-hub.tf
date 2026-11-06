# ==============================================================================
# Fechamento Bilateral de VPC Peering no Hub (hub-facilitador/peering-hub.tf)
# ==============================================================================
# O Facilitador possui duas formas de aceitar os VPC Peerings dos alunos:
# 1. AUTOMÁTICA (Recomendada durante a aula):
#    Executar `./scripts/auto-accept-peerings.sh` (ou o reconciliador no Cloud Run),
#    que varre os projetos dos grupos a cada 15s e aceita automaticamente todo
#    peering pendente na `vpc-hub-turma-a` (Alunos 01..20) ou `vpc-hub-turma-b` (21..40).
# 2. DECLARATIVA VIA TERRAFORM (Abaixo):
#    Preenchendo a variável `active_student_peerings` no `terraform.tfvars`.

resource "google_compute_network_peering" "hub_para_aluno" {
  for_each = var.active_student_peerings

  name = format("peer-hub-to-aluno-%02d", each.value.student_id)

  # Seleciona automaticamente vpc-hub-turma-a (1..20) ou vpc-hub-turma-b (21..40):
  network = (
    each.value.student_id <= 20
    ? google_compute_network.vpc_hub["turma_a"].self_link
    : google_compute_network.vpc_hub["turma_b"].self_link
  )

  # Aponta para a VPC criada pelo aluno no projeto do grupo dele:
  peer_network = format(
    "projects/%s/global/networks/vpc-redes-tf-aluno-%02d",
    each.value.student_project_id,
    each.value.student_id
  )
}
