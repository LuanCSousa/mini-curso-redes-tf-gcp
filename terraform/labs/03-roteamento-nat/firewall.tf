# ==============================================================================
# Regras de Firewall Stateful e Microsegmentação (labs/03-roteamento-nat/firewall.tf)
# ==============================================================================

resource "google_compute_firewall" "allow_ssh_iap" {
  name          = "fw-allow-ssh-iap-${local.student_suffix}"
  description   = "Permite SSH (TCP 22) exclusivamente a partir do bloco oficial do Google Cloud IAP"
  network       = google_compute_network.vpc_aluno.id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh-iap"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Firewall stateful: as respostas do Hub/Internet voltam sem regra extra de ingress.
resource "google_compute_firewall" "allow_internal_icmp" {
  name          = "fw-allow-internal-icmp-${local.student_suffix}"
  description   = "Permite ping (ICMP) iniciado de dentro da propria sub-rede"
  network       = google_compute_network.vpc_aluno.id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [local.subnet_cidr]

  allow {
    protocol = "icmp"
  }
}
