# ==============================================================================
# Composição de Infraestrutura via Módulos (labs/05-boas-praticas-modules/main.tf)
# ==============================================================================
# DEMONSTRAÇÃO DE ENGENHARIA CLOUD (ETAPA 05):
# Compare este arquivo enxuto e expressivo com os múltiplos recursos soltos que
# escrevemos nas Etapas 01 a 04. Aqui cada módulo tem responsabilidade única e
# se conecta aos demais por meio de contratos claros (variables -> outputs).
#
# Os nomes e descrições são IDÊNTICOS aos do live-coding (Etapa 04). Junto com o
# arquivo moved.tf, isso permite migrar a infraestrutura já criada para módulos
# SEM destruir nada (veja o README desta etapa).

# ------------------------------------------------------------------------------
# 1. Módulo de Rede Base (VPC Custom + Sub-rede Regional + Cloud Router + NAT)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc-network"

  project_id         = var.project_id
  vpc_name           = local.vpc_name
  vpc_description    = "VPC customizada do participante ${local.student_suffix} - Minicurso Redes.tf (e-info FACAPE)"
  region             = var.region
  subnet_name        = local.subnet_name
  subnet_description = "Sub-rede regional ${local.subnet_cidr} do participante ${local.student_suffix}"
  subnet_cidr        = local.subnet_cidr
  enable_cloud_nat   = true
  router_name        = local.router_name
  router_description = "Cloud Router regional do participante ${local.student_suffix} para orquestrar o Cloud NAT"
  nat_name           = local.nat_name
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

  # Firewall stateful: basta a própria sub-rede; respostas do Hub voltam sozinhas.
  internal_source_ranges = [module.vpc.subnet_cidr]
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
