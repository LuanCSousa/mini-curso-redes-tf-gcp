# ==============================================================================
# Saídas / Outputs (labs/03-roteamento-nat/outputs.tf)
# ==============================================================================

output "vpc_name" {
  description = "Nome da VPC Global criada no Google Cloud."
  value       = google_compute_network.vpc_aluno.name
}

output "subnet_cidr" {
  description = "Bloco IPv4 CIDR alocado para a sub-rede do aluno."
  value       = google_compute_subnetwork.subnet_principal.ip_cidr_range
}

output "vm_name" {
  description = "Nome da instância de VM privada criada."
  value       = google_compute_instance.vm_aluno.name
}

output "vm_internal_ip" {
  description = "IP privado interno atribuído à VM (.2)."
  value       = google_compute_instance.vm_aluno.network_interface[0].network_ip
}

output "router_name" {
  description = "Nome do Cloud Router regional criado."
  value       = google_compute_router.router_aluno.name
}

output "nat_name" {
  description = "Nome do gateway Cloud NAT (SNAT) criado."
  value       = google_compute_router_nat.nat_aluno.name
}

output "ssh_iap_command" {
  description = "Comando pronto para conectar via SSH na VM privada usando o túnel Cloud IAP."
  value       = "gcloud compute ssh ${google_compute_instance.vm_aluno.name} --zone=${var.zone} --project=${var.project_id} --tunnel-through-iap"
}
