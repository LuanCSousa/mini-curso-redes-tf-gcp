# ==============================================================================
# Módulo: vpc-network — Contrato de Saída (modules/vpc-network/outputs.tf)
# ==============================================================================
# Os outputs de um módulo servem como ponte para conectar outros módulos
# (ex: passar `module.vpc.vpc_id` para o módulo `firewall-rules`).

output "vpc_id" {
  description = "ID completo da VPC criada."
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Nome da VPC criada."
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "Self-link da VPC criada (utilizado pelo módulo vpc-peering)."
  value       = google_compute_network.vpc.self_link
}

output "subnet_id" {
  description = "ID completo da sub-rede regional criada."
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "Nome da sub-rede regional criada."
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_cidr" {
  description = "Bloco IPv4 CIDR da sub-rede criada."
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "subnet_gateway_ip" {
  description = "IP do Default Gateway Virtual (.1) da sub-rede."
  value       = google_compute_subnetwork.subnet.gateway_address
}

output "nat_name" {
  description = "Nome do Cloud NAT criado (ou null caso enable_cloud_nat = false)."
  value       = var.enable_cloud_nat ? google_compute_router_nat.nat[0].name : null
}
