# ==============================================================================
# Roteamento e Tradução de Endereços — SNAT (labs/04-vpc-peering-hub/nat.tf)
# ==============================================================================

resource "google_compute_router" "router_aluno" {
  name        = local.router_name
  description = "Cloud Router regional do participante ${local.student_suffix} para orquestrar o Cloud NAT"
  network     = google_compute_network.vpc_aluno.id
  region      = var.region
}

resource "google_compute_router_nat" "nat_aluno" {
  name                               = local.nat_name
  router                             = google_compute_router.router_aluno.name
  region                             = google_compute_router.router_aluno.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
