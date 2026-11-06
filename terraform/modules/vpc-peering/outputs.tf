# ==============================================================================
# Módulo: vpc-peering — Contrato de Saída (modules/vpc-peering/outputs.tf)
# ==============================================================================

output "peering_name" {
  description = "Nome da conexão de VPC Network Peering."
  value       = google_compute_network_peering.peering.name
}

output "peering_state" {
  description = "Estado atual do Peering (INACTIVE ou ACTIVE)."
  value       = google_compute_network_peering.peering.state
}

output "peering_state_details" {
  description = "Detalhes informativos retornados pela API do GCP sobre o estado do Peering."
  value       = google_compute_network_peering.peering.state_details
}

output "peer_network_self_link" {
  description = "Self-link completo da VPC remota conectada."
  value       = local.peer_network_self_link
}
