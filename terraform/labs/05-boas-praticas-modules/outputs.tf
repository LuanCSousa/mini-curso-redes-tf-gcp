# ==============================================================================
# Saídas / Outputs Compostos (labs/05-boas-praticas-modules/outputs.tf)
# ==============================================================================

output "vpc_name" {
  description = "Nome da VPC criada pelo módulo vpc-network."
  value       = module.vpc.vpc_name
}

output "subnet_cidr" {
  description = "Bloco CIDR da sub-rede criada pelo módulo vpc-network."
  value       = module.vpc.subnet_cidr
}

output "nat_name" {
  description = "Nome do Cloud NAT gerenciado pelo módulo vpc-network."
  value       = module.vpc.nat_name
}

output "peering_state" {
  description = "Estado do VPC Peering gerenciado pelo módulo vpc-peering."
  value       = module.peering_hub.peering_state
}

output "vm_internal_ip" {
  description = "IP privado da VM conectada aos módulos."
  value       = google_compute_instance.vm_aluno.network_interface[0].network_ip
}
