# ==============================================================================
# Composição de Infraestrutura via Módulos (labs/05-boas-praticas-modules/main.tf)
# ==============================================================================
# DEMONSTRAÇÃO DE ENGENHARIA CLOUD (ETAPA 05):
# Compare este arquivo enxuto e expressivo com os múltiplos recursos soltos que
# escrevemos nas Etapas 01 a 04. Aqui cada módulo tem responsabilidade única e
# se conecta aos demais por meio de contratos claros (variables -> outputs).

# ------------------------------------------------------------------------------
# 1. Módulo de Rede Base (VPC Custom + Sub-rede Regional + Cloud Router + NAT)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc-network"

  project_id       = var.project_id
  vpc_name         = local.vpc_name
  region           = var.region
  subnet_name      = local.subnet_name
  subnet_cidr      = local.subnet_cidr
  enable_cloud_nat = true
  router_name      = "router-${var.region}-${local.student_suffix}"
  nat_name         = "nat-${var.region}-${local.student_suffix}"
}

# ------------------------------------------------------------------------------
# 2. Módulo de Governança de Perímetro (Firewall Cloud IAP + ICMP Interno)
# ------------------------------------------------------------------------------
module "firewall" {
  source = "../../modules/firewall-rules"

  project_id      = var.project_id
  vpc_id          = module.vpc.vpc_id
  name_suffix     = local.student_suffix
  enable_iap_ssh  = true
  iap_target_tags = ["ssh-iap"]

  internal_source_ranges = [
    module.vpc.subnet_cidr,
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

# ------------------------------------------------------------------------------
# 3. Módulo de Interconexão Hub-and-Spoke (VPC Network Peering)
# ------------------------------------------------------------------------------
module "peering_hub" {
  source = "../../modules/vpc-peering"

  peering_name        = "peer-${local.student_suffix}-to-hub"
  local_vpc_self_link = module.vpc.vpc_self_link
  peer_project_id     = var.hub_project_id
  peer_vpc_name       = local.hub_vpc_name
}
