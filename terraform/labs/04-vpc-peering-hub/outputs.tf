# ==============================================================================
# Saídas / Outputs (labs/04-vpc-peering-hub/outputs.tf)
# ==============================================================================

output "vpc_name" {
  description = "Nome da VPC Global do aluno (Spoke)."
  value       = google_compute_network.vpc_aluno.name
}

output "subnet_cidr" {
  description = "Bloco IPv4 CIDR exclusivo da sub-rede do aluno."
  value       = google_compute_subnetwork.subnet_principal.ip_cidr_range
}

output "vm_internal_ip" {
  description = "IP privado interno atribuído à VM do aluno."
  value       = google_compute_instance.vm_aluno.network_interface[0].network_ip
}

output "peering_name" {
  description = "Nome da conexão de VPC Network Peering criada."
  value       = google_compute_network_peering.peering_aluno_para_hub.name
}

output "peering_state" {
  description = "Estado atual do VPC Peering (INACTIVE até o Hub aceitar; ACTIVE quando conectado!)."
  value       = google_compute_network_peering.peering_aluno_para_hub.state
}

output "hub_conectado" {
  description = "Qual VPC do Hub Central e qual IP privado de destino sua rede utiliza."
  value       = "${local.hub_vpc_name} (${local.hub_subnet_cidr}) -> VM Coletora: ${local.hub_target_ip}"
}

output "ssh_iap_command" {
  description = "Comando para conectar via SSH na sua VM privada."
  value       = "gcloud compute ssh ${google_compute_instance.vm_aluno.name} --zone=${var.zone} --project=${var.project_id} --tunnel-through-iap"
}

output "comando_checkin_mural" {
  description = "Rode este comando DENTRO do SSH da sua VM privada após o Peering ficar ACTIVE para aparecer no telão!"
  value       = "curl -s -X POST http://${local.hub_target_ip}/checkin -H 'Content-Type: application/json' -d '{\"student_id\": ${var.student_id}, \"nome\": \"${var.student_name}\", \"subnet\": \"${local.subnet_cidr}\"}'"
}

output "routes_list_command" {
  description = "Comando para inspecionar a tabela de rotas da sua VPC (rotas de sub-rede, padrão e a explícita)."
  value       = "gcloud compute routes list --project=${var.project_id} --filter=\"network~${google_compute_network.vpc_aluno.name}\""
}

output "peering_routes_command" {
  description = "Comando para ver as rotas IMPORTADAS do Hub via Peering (ex: 10.0.1.0/24)."
  value       = "gcloud compute networks peerings list-routes ${google_compute_network_peering.peering_aluno_para_hub.name} --network=${google_compute_network.vpc_aluno.name} --region=${var.region} --direction=INCOMING --project=${var.project_id}"
}
