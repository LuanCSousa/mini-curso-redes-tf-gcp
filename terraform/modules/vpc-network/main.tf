# ==============================================================================
# Módulo: vpc-network — Recursos Encapsulados (modules/vpc-network/main.tf)
# ==============================================================================
# Este módulo encapsula o padrão corporativo de fundação de rede:
# VPC Customizada + Sub-rede Regional + Cloud Router + Cloud NAT condicional.

locals {
  effective_router_name = var.router_name != "" ? var.router_name : "router-${var.region}-${var.vpc_name}"
  effective_nat_name    = var.nat_name != "" ? var.nat_name : "nat-${var.region}-${var.vpc_name}"
}

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  description             = var.vpc_description
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

resource "google_compute_subnetwork" "subnet" {
  project                  = var.project_id
  name                     = var.subnet_name
  description              = var.subnet_description
  network                  = google_compute_network.vpc.id
  region                   = var.region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_router" "router" {
  count       = var.enable_cloud_nat ? 1 : 0
  project     = var.project_id
  name        = local.effective_router_name
  description = var.router_description
  network     = google_compute_network.vpc.id
  region      = var.region
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_cloud_nat ? 1 : 0
  project                            = var.project_id
  name                               = local.effective_nat_name
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
