# ==============================================================================
# Saídas / Outputs (pre-material/foundation-check/outputs.tf)
# ==============================================================================

output "cartao_foundation_aluno" {
  description = "Resumo visual confirmando que o seu ambiente está pronto para o minicurso Redes.tf."
  value       = <<-EOT

  ====================================================================
    FOUNDATION VALIDADO COM SUCESSO — REDES.TF (e-info / FACAPE)
  ====================================================================
    Participante      : ${var.student_name} (${local.student_suffix})
    Projeto GCP Ativo : ${var.project_id}
    Região Padrão     : ${var.region} (Zonas ativas detectadas: ${length(data.google_compute_zones.zonas_disponiveis.names)})
  --------------------------------------------------------------------
    SEU PLANO DE REDE PARA O LIVE CODING:
    • Nome da sua VPC : ${local.vpc_name}
    • Nome da Subnet  : ${local.subnet_name}
    • Sua Sub-rede    : ${local.subnet_cidr} (Gateway: ${local.gateway_ip})
    • Hub de Peering  : ${local.hub_vpc_name} (${local.hub_subnet} -> Alvo: ${local.hub_target_ip})
  ====================================================================
  EOT
}

output "dados_tecnicos_aluno" {
  description = "Objeto estruturado com os parâmetros calculados do aluno."
  value       = terraform_data.comprovante_foundation.output
}
