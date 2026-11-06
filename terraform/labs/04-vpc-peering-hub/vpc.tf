# ==============================================================================
# Rede VPC Global e Sub-rede Regional (labs/04-vpc-peering-hub/vpc.tf)
# ==============================================================================

resource "google_compute_network" "vpc_aluno" {
  name                    = local.vpc_name
  description             = "VPC customizada do participante ${local.student_suffix} - Minicurso Redes.tf (e-info FACAPE)"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet_principal" {
  name                     = local.subnet_name
  description              = "Sub-rede regional ${local.subnet_cidr} do participante ${local.student_suffix}"
  network                  = google_compute_network.vpc_aluno.id
  region                   = var.region
  ip_cidr_range            = local.subnet_cidr
  private_ip_google_access = true
}
