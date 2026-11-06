# ==============================================================================
# Módulo: firewall-rules — Contrato de Saída (modules/firewall-rules/outputs.tf)
# ==============================================================================

output "ssh_iap_rule_name" {
  description = "Nome da regra de firewall do Cloud IAP."
  value       = var.enable_iap_ssh ? google_compute_firewall.allow_ssh_iap[0].name : null
}

output "internal_icmp_rule_name" {
  description = "Nome da regra de firewall de tráfego interno (ICMP/HTTP)."
  value       = google_compute_firewall.allow_internal_icmp.name
}

output "iap_target_tags" {
  description = "Network Tags configuradas para acesso SSH via IAP."
  value       = var.iap_target_tags
}
