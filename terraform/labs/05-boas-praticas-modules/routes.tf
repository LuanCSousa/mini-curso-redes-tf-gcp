# ==============================================================================
# Rota Estática Explícita (labs/05-boas-praticas-modules/routes.tf)
# ==============================================================================
# Mesmo recurso (e mesmo endereço no state) da Etapa 03/04. Ficou fora dos
# módulos de propósito: é uma decisão específica deste ambiente, não do padrão
# de rede reutilizável. Exercício pós-curso: transformá-la em uma variável
# opcional do módulo vpc-network (ex: `extra_routes`).

resource "google_compute_route" "internet_explicita" {
  name        = local.route_name
  description = "Rota padrao explicita (prioridade 900) para as VMs com a tag ${local.student_suffix}"
  network     = module.vpc.vpc_id

  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 900
  tags             = [local.student_suffix]
}
