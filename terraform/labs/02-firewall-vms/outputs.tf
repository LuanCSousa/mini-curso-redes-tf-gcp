# ==============================================================================
# Saídas / Outputs (labs/02-firewall-vms/outputs.tf)
# ==============================================================================

output "vpc_name" {
  description = "Nome da VPC Global criada no Google Cloud."
  value       = google_compute_network.vpc_aluno.name
}

output "subnet_cidr" {
  description = "Bloco IPv4 CIDR alocado para a sub-rede do aluno."
  value       = google_compute_subnetwork.subnet_principal.ip_cidr_range
}

output "subnet_gateway_ip" {
  description = "IP do Default Gateway Virtual (.1) reservado pela SDN Andromeda."
  value       = google_compute_subnetwork.subnet_principal.gateway_address
}

output "vm_name" {
  description = "Nome da instância de VM privada criada."
  value       = google_compute_instance.vm_aluno.name
}

output "vm_internal_ip" {
  description = "IP privado interno atribuído à VM (repare que começa em .2 pois o .1 é o Gateway!)."
  value       = google_compute_instance.vm_aluno.network_interface[0].network_ip
}

output "ssh_iap_command" {
  description = "Comando pronto para conectar via SSH na VM privada usando o túnel Cloud IAP."
  value       = "gcloud compute ssh ${google_compute_instance.vm_aluno.name} --zone=${var.zone} --project=${var.project_id} --tunnel-through-iap"
}
