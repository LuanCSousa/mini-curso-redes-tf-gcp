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
