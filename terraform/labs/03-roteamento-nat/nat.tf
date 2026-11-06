# ==============================================================================
# Roteamento e Tradução de Endereços — SNAT (labs/03-roteamento-nat/nat.tf)
# ==============================================================================
# CONCEITO DE REDES (POR QUE O PING 8.8.8.8 FALHOU ANTES DO ALMOÇO?):
# 1. Uma VM privada (ex: 10.7.0.2) possui um endereço RFC 1918 que NÃO é
#    roteável na Internet Pública. Se um pacote sair com IP de origem 10.7.0.2,
#    ele é descartado imediatamente na borda da rede.
# 2. Solução: SNAT (Source Network Address Translation) via Cloud NAT!
#    - Na saída: o Cloud NAT substitui o IP de origem privado (10.7.0.2:porta)
#      por um IP Público compartilhado da Google e grava essa tupla na tabela
#      de estados.
#    - Na resposta: quando o 8.8.8.8 devolve o pacote para o IP Público do NAT,
#      ele consulta a tabela de estados e entrega de volta para 10.7.0.2.
#    - Segurança unidirecional: NINGUÉM na internet consegue iniciar uma conexão
#      de fora para dentro através do Cloud NAT!

# ------------------------------------------------------------------------------
# 1. Cloud Router Regional (Plano de Controle da Rede)
# ------------------------------------------------------------------------------
resource "google_compute_router" "router_aluno" {
  name        = local.router_name
  description = "Cloud Router regional do participante ${local.student_suffix} para orquestrar o Cloud NAT"
  network     = google_compute_network.vpc_aluno.id
  region      = var.region
}

# ------------------------------------------------------------------------------
# 2. Cloud NAT (Gateway SNAT Gerenciado pelo SDN Andromeda)
# ------------------------------------------------------------------------------
resource "google_compute_router_nat" "nat_aluno" {
  name   = local.nat_name
  router = google_compute_router.router_aluno.name
  region = google_compute_router.router_aluno.region

  # Alocação automática de IPs externos de saída pelo próprio Google Cloud:
  nat_ip_allocate_option = "AUTO_ONLY"

  # Aplica SNAT automaticamente para todas as sub-redes da região:
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Boas práticas de observabilidade: registrar eventuais erros de exaustão de portas
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
