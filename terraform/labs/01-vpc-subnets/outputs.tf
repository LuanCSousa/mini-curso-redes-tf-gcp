# ==============================================================================
# Saídas / Outputs (labs/01-vpc-subnets/outputs.tf)
# ==============================================================================
# Os outputs exibem no terminal informações retornadas pela API do Google Cloud
# logo após o 'terraform apply'.

output "vpc_name" {
  description = "Nome da VPC Global criada no Google Cloud."
  value       = google_compute_network.vpc_aluno.name
}

output "vpc_id" {
  description = "Identificador completo (URI) da VPC no GCP."
  value       = google_compute_network.vpc_aluno.id
}

output "subnet_name" {
  description = "Nome da Sub-rede Regional criada."
  value       = google_compute_subnetwork.subnet_principal.name
}

output "subnet_cidr" {
  description = "Bloco IPv4 CIDR alocado para a sub-rede do aluno."
  value       = google_compute_subnetwork.subnet_principal.ip_cidr_range
}

output "subnet_gateway_ip" {
  description = "IP do Default Gateway Virtual (.1) reservado automaticamente pela SDN Andromeda do GCP."
  value       = google_compute_subnetwork.subnet_principal.gateway_address
}
