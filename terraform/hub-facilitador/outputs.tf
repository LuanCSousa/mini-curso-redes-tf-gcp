# ==============================================================================
# Saídas / Outputs do Hub Central (hub-facilitador/outputs.tf)
# ==============================================================================

output "hub_turma_a_summary" {
  description = "Dados da VPC e VM Coletora da Turma A (Alunos 01 a 20)."
  value = {
    vpc_name     = google_compute_network.vpc_hub["turma_a"].name
    subnet_cidr  = google_compute_subnetwork.subnet_hub["turma_a"].ip_cidr_range
    collector_ip = google_compute_instance.vm_coletora["turma_a"].network_interface[0].network_ip
  }
}

output "hub_turma_b_summary" {
  description = "Dados da VPC e VM Coletora da Turma B (Alunos 21 a 40)."
  value = {
    vpc_name     = google_compute_network.vpc_hub["turma_b"].name
    subnet_cidr  = google_compute_subnetwork.subnet_hub["turma_b"].ip_cidr_range
    collector_ip = google_compute_instance.vm_coletora["turma_b"].network_interface[0].network_ip
  }
}

output "tunnel_mural_turma_a_cmd" {
  description = "Comando para abrir o painel local da VM Coletora Turma A no navegador do Facilitador via IAP."
  value       = "gcloud compute start-iap-tunnel vm-coletora-turma-a 80 --local-host-port=localhost:8081 --zone=${var.zone} --project=${var.hub_project_id}"
}

output "tunnel_mural_turma_b_cmd" {
  description = "Comando para abrir o painel local da VM Coletora Turma B no navegador do Facilitador via IAP."
  value       = "gcloud compute start-iap-tunnel vm-coletora-turma-b 80 --local-host-port=localhost:8082 --zone=${var.zone} --project=${var.hub_project_id}"
}
