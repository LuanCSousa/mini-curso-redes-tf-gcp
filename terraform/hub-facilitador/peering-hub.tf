# ==============================================================================
# Fechamento Bilateral de VPC Peering no Hub (hub-facilitador/peering-hub.tf)
# ==============================================================================
# O Facilitador possui duas formas de aceitar os VPC Peerings dos alunos.
# ATENÇÃO: elas são MUTUAMENTE EXCLUSIVAS. Ambas criam peerings com o mesmo nome
# (`peer-hub-to-aluno-XX`); usar as duas ao mesmo tempo gera erro "already exists".
#
# 1. AUTOMÁTICA (Recomendada durante a aula):
#    Executar `./scripts/auto-accept-peerings.sh` no terminal do facilitador.
#    Ele varre os projetos dos grupos a cada 15s e cria o lado do Hub para toda
#    `vpc-redes-tf-aluno-XX` encontrada: `vpc-hub-turma-a` (Alunos 01..20) ou
#    `vpc-hub-turma-b` (21..40). Nesse modo, deixe `active_student_peerings = {}`.
# 2. DECLARATIVA VIA TERRAFORM (Abaixo):
#    Preenchendo a variável `active_student_peerings` no `terraform.tfvars`
#    (e NÃO rodando o script de auto-aceite).

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
