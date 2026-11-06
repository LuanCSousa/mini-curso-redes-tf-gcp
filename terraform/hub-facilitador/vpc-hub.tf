# ==============================================================================
# VPCs do Hub Central, Cloud NAT e Regras de Firewall (hub-facilitador/vpc-hub.tf)
# ==============================================================================
# Cria automaticamente as duas estruturas de Hub:
# - `vpc-hub-turma-a` (10.0.1.0/24) -> Recebe VPC Peering dos Alunos 01 a 20
# - `vpc-hub-turma-b` (10.0.2.0/24) -> Recebe VPC Peering dos Alunos 21 a 40

# ------------------------------------------------------------------------------
# 1. VPCs Globais do Hub (Turma A e Turma B)
# ------------------------------------------------------------------------------
resource "google_compute_network" "vpc_hub" {
  for_each = local.hubs

  name                    = each.value.vpc_name
  description             = "VPC Central do Facilitador (${each.value.student_range}) - Minicurso Redes.tf"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# ------------------------------------------------------------------------------
# 2. Sub-redes Regionais do Hub (10.0.1.0/24 e 10.0.2.0/24)
# ------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnet_hub" {
  for_each = local.hubs

  name                     = each.value.subnet_name
  description              = "Sub-rede do Hub Central (${each.value.student_range})"
  network                  = google_compute_network.vpc_hub[each.key].id
  region                   = var.region
  ip_cidr_range            = each.value.subnet_cidr
  private_ip_google_access = true
}

# ------------------------------------------------------------------------------
# 3. Cloud Router + Cloud NAT nas 2 VPCs do Hub
#    (Permite que as VMs coletoras enviem eventos para o Cloud Run sem IP público)
# ------------------------------------------------------------------------------
resource "google_compute_router" "router_hub" {
  for_each = local.hubs

  name    = "router-${each.value.vpc_name}"
  network = google_compute_network.vpc_hub[each.key].id
  region  = var.region
}

resource "google_compute_router_nat" "nat_hub" {
  for_each = local.hubs

  name                               = "nat-${each.value.vpc_name}"
  router                             = google_compute_router.router_hub[each.key].name
  region                             = google_compute_router.router_hub[each.key].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ------------------------------------------------------------------------------
# 4. Firewall: SSH via Cloud IAP para Administração do Facilitador
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "hub_allow_ssh_iap" {
  for_each = local.hubs

  name          = "fw-${each.value.vpc_name}-allow-ssh-iap"
  description   = "Permite SSH e TCP Forwarding via Cloud IAP para as VMs coletoras do Hub"
  network       = google_compute_network.vpc_hub[each.key].id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["hub-collector"]

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
}

# ------------------------------------------------------------------------------
# 5. Firewall: Liberar Ping (ICMP) e Check-in HTTP (TCP 80) vindos das
#    Sub-redes Privadas dos Alunos (10.1.0.0/24 até 10.40.0.0/24) via Peering
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "hub_allow_students_peering" {
  for_each = local.hubs

  name          = "fw-${each.value.vpc_name}-allow-students"
  description   = "Permite ICMP (ping) e HTTP (POST /checkin) vindos das sub-redes 10.<ID>.0.0/24 dos alunos via VPC Peering"
  network       = google_compute_network.vpc_hub[each.key].id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["hub-collector"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
