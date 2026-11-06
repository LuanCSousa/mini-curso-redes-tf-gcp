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
  description = "Permite SSH (TCP 22) exclusivamente a partir do bloco do Google Cloud IAP para VMs com a tag ssh-iap"
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
# 2. Regra de Entrada: Diagnóstico Interno (ICMP / Ping e HTTP interno)
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_internal_icmp" {
  name        = "fw-allow-internal-icmp-${local.student_suffix}"
  description = "Permite ping (ICMP) e HTTP entre a sub-rede do aluno e as VPCs do Hub Central"
  network     = google_compute_network.vpc_aluno.id

  direction = "INGRESS"
  priority  = 1000

  # Permite tráfego vindo da própria sub-rede do aluno e das 2 sub-redes do Hub Central:
  source_ranges = [
    local.subnet_cidr,
    "10.0.1.0/24", # Hub Turma A (Alunos 01 a 20)
    "10.0.2.0/24"  # Hub Turma B (Alunos 21 a 40)
  ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
}
