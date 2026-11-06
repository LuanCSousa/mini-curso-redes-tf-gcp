# ==============================================================================
# Regras de Firewall Stateful e Microsegmentação (labs/04-vpc-peering-hub/firewall.tf)
# ==============================================================================

resource "google_compute_firewall" "allow_ssh_iap" {
  name          = "fw-allow-ssh-iap-${local.student_suffix}"
  description   = "Permite SSH (TCP 22) exclusivamente a partir do bloco do Google Cloud IAP para VMs com a tag ssh-iap"
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

resource "google_compute_firewall" "allow_internal_icmp" {
  name        = "fw-allow-internal-icmp-${local.student_suffix}"
  description = "Permite ping (ICMP) e HTTP entre a sub-rede do aluno e as VPCs do Hub Central"
  network     = google_compute_network.vpc_aluno.id
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [
    local.subnet_cidr,
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
}
