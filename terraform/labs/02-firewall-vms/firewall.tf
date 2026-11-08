# ==============================================================================
# Regras de Firewall Stateful e Microsegmentação (labs/02-firewall-vms/firewall.tf)
# ==============================================================================
# CONCEITO DE FIREWALL NO GCP:
# 1. Regras Implícitas de toda VPC customizada:
#    - Allow All Egress (prioridade 65535 -> 0.0.0.0/0): permite saída.
#    - Deny All Ingress (prioridade 65535 -> 0.0.0.0/0): bloqueia toda entrada!
# 2. Firewall Stateful (Conntrack):
#    - Se uma conexão de entrada (INGRESS) for autorizada por uma regra, os
#      pacotes de resposta voltam automaticamente sem precisar de regra extra.
# 3. Cloud IAP (Identity-Aware Proxy):
#    - Em vez de expor a porta 22 para o mundo (0.0.0.0/0) e colocar IP público
#      na VM, liberamos apenas o bloco oficial do túnel TCP da Google:
#      35.235.240.0/20.

# ------------------------------------------------------------------------------
# 1. Regra de Entrada: SSH Seguro via Túnel Cloud IAP (Zero-Trust)
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_ssh_iap" {
  name        = "fw-allow-ssh-iap-${local.student_suffix}"
  description = "Permite SSH (TCP 22) exclusivamente a partir do bloco oficial do Google Cloud IAP"
  network     = google_compute_network.vpc_aluno.id

  direction = "INGRESS"
  priority  = 1000

  # Faixa de IPs oficial dos proxies do Google Cloud IAP TCP Forwarding:
  source_ranges = ["35.235.240.0/20"]

  # Microsegmentação com Network Tags:
  # Esta regra só se aplica às VMs que tiverem a tag "ssh-iap".
  target_tags = ["ssh-iap"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# ------------------------------------------------------------------------------
# 2. Regra de Entrada: Diagnóstico Interno (ICMP / Ping dentro da sub-rede)
# ------------------------------------------------------------------------------
# Repare no que NÃO precisamos liberar:
# - Nenhuma regra para a VM sair para a internet ou para o Hub: o EGRESS já é
#   permitido pela regra implícita (prioridade 65535).
# - Nenhuma regra para as RESPOSTAS voltarem: o firewall é STATEFUL. Na Etapa 04,
#   quando nossa VM fizer `ping`/`curl` para o Hub (10.0.1.10 / 10.0.2.10), as
#   respostas entram automaticamente porque pertencem a uma conexão que NÓS
#   iniciamos. Princípio do menor privilégio: só abrimos o que é iniciado de fora.
resource "google_compute_firewall" "allow_internal_icmp" {
  name        = "fw-allow-internal-icmp-${local.student_suffix}"
  description = "Permite ping (ICMP) iniciado de dentro da propria sub-rede"
  network     = google_compute_network.vpc_aluno.id

  direction = "INGRESS"
  priority  = 1000

  # Somente a própria sub-rede do aluno (10.<ID>.0.0/24):
  source_ranges = [local.subnet_cidr]

  allow {
    protocol = "icmp"
  }
}
