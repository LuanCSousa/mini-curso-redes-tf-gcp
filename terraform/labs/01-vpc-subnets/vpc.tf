# ==============================================================================
# Rede VPC Global e Sub-rede Regional (labs/01-vpc-subnets/vpc.tf)
# ==============================================================================
# CONCEITO DE REDES NO GCP:
# 1. VPC (Virtual Private Cloud): No Google Cloud, a VPC é um objeto GLOBAL
#    operado pela SDN Andromeda. Ela não possui faixa de IP própria!
# 2. Sub-rede (Subnetwork): É um objeto REGIONAL (ex: us-central1) ao qual
#    atribuímos efetivamente o bloco CIDR (ex: 10.7.0.0/24).

# ------------------------------------------------------------------------------
# 1. Criação da VPC em Modo Customizado
# ------------------------------------------------------------------------------
resource "google_compute_network" "vpc_aluno" {
  name        = local.vpc_name
  description = "VPC customizada do participante ${local.student_suffix} - Minicurso Redes.tf (e-info FACAPE)"

  # IMPORTANTE: Sempre defina auto_create_subnetworks = false em ambientes reais!
  # O modo automático (true) cria 1 sub-rede em cada região do mundo usando o
  # bloco fixo 10.128.0.0/9, o que causa colisão de IPs (CIDR overlap) e impede
  # o fechamento de VPC Network Peering ou VPNs entre projetos.
  auto_create_subnetworks = false

  # Modo de roteamento dinâmico (Cloud Router / BGP):
  # REGIONAL = o Cloud Router anuncia/aprende apenas sub-redes da mesma região.
  routing_mode = "REGIONAL"
}

# ------------------------------------------------------------------------------
# 2. Criação da Sub-rede Regional com CIDR Dinâmico (10.<student_id>.0.0/24)
# ------------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnet_principal" {
  name        = local.subnet_name
  description = "Sub-rede regional ${local.subnet_cidr} do participante ${local.student_suffix}"

  # Vínculo explícito (Grafo de Dependência):
  # O Terraform sabe que precisa criar a VPC antes da Sub-rede e destruir a
  # Sub-rede antes da VPC porque referenciamos google_compute_network.vpc_aluno.id
  network = google_compute_network.vpc_aluno.id
  region  = var.region

  # Bloco CIDR /24 exclusivo do aluno:
  # No GCP, 4 IPs são reservados automaticamente em qualquer sub-rede:
  # - 10.<ID>.0.0   : Endereço de Rede
  # - 10.<ID>.0.1   : Default Gateway Virtual (SDN Andromeda)
  # - 10.<ID>.0.254 : Reservado para uso futuro do GCP
  # - 10.<ID>.0.255 : Endereço de Broadcast (RFC)
  # Sobram 252 IPs utilizáveis (.2 até .253).
  ip_cidr_range = local.subnet_cidr

  # Private Google Access:
  # Permite que VMs sem IP externo (100% privadas) acessem APIs do Google
  # (Cloud Storage, Artifact Registry, Cloud Logging) pela rede interna da Google.
  private_ip_google_access = true
}
