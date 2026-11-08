# ==============================================================================
# Tabela de Roteamento — Rota Estática Explícita (labs/03-roteamento-nat/routes.tf)
# ==============================================================================
# CONCEITO DE REDES (TABELA DE ROTAS / NEXT-HOP):
# Toda VPC custom já nasce com rotas criadas pelo próprio GCP:
#   - Rotas de sub-rede (ex: 10.7.0.0/24 -> "local"), uma por sub-rede;
#   - Rota padrão 0.0.0.0/0 -> default-internet-gateway, PRIORIDADE 1000.
#
# Aqui declaramos como CÓDIGO uma rota estática equivalente à rota padrão, mas:
#   1. com prioridade 900 (menor número = MAIS preferida que a implícita 1000);
#   2. aplicada SOMENTE às VMs com a network tag do aluno (`aluno-XX`).
# Assim enxergamos os 3 campos clássicos de uma entrada de tabela de rotas:
#   DESTINO (dest_range) | NEXT-HOP (next_hop_gateway) | MÉTRICA (priority)
#
# Lembre: a rota leva o pacote até a "borda" da Google, mas uma VM só com IP
# privado (RFC 1918) continua precisando do Cloud NAT (nat.tf) para ter um IP
# público de origem válido na internet. ROTA != NAT!
#
# Inspecione a tabela completa da sua VPC com:
#   gcloud compute routes list --filter="network~vpc-redes-tf-aluno-XX"

resource "google_compute_route" "internet_explicita" {
  name        = local.route_name
  description = "Rota padrao explicita (prioridade 900) para as VMs com a tag ${local.student_suffix}"
  network     = google_compute_network.vpc_aluno.id

  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 900

  # Rota aplicada apenas às VMs que possuem esta network tag (ver compute.tf):
  tags = [local.student_suffix]
}
