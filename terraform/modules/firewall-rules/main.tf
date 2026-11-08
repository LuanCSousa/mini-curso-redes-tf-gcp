# ==============================================================================
# Módulo: firewall-rules — Recursos Encapsulados (modules/firewall-rules/main.tf)
# ==============================================================================

resource "google_compute_firewall" "allow_ssh_iap" {
  count         = var.enable_iap_ssh ? 1 : 0
  project       = var.project_id
  name          = "fw-allow-ssh-iap-${var.name_suffix}"
  description   = "Permite SSH (TCP 22) exclusivamente a partir do bloco oficial do Google Cloud IAP"
  network       = var.vpc_id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = var.iap_target_tags

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Firewall stateful: respostas de conexões iniciadas pela VM voltam sem regra extra.
resource "google_compute_firewall" "allow_internal_icmp" {
  project       = var.project_id
  name          = "fw-allow-internal-icmp-${var.name_suffix}"
  description   = "Permite ping (ICMP) iniciado de dentro da propria sub-rede"
  network       = var.vpc_id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = var.internal_source_ranges

  allow {
    protocol = "icmp"
  }
}
