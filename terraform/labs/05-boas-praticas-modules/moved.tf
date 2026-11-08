# ==============================================================================
# Refatoração sem Downtime com Blocos `moved` (labs/05-boas-praticas-modules/moved.tf)
# ==============================================================================
# PROBLEMA: ao mover um recurso para dentro de um módulo, o ENDEREÇO dele no
# state muda (ex: google_compute_network.vpc_aluno -> module.vpc.google_compute_network.vpc).
# Sem aviso, o Terraform entenderia "destruir o antigo + criar o novo" — o que
# derrubaria a VPC, a VM e o Peering!
#
# SOLUÇÃO (Terraform >= 1.1): blocos `moved` dizem ao Terraform que é o MESMO
# objeto real, apenas com um novo endereço. O `terraform plan` passa a mostrar
# "has moved to" e "0 to add, 0 to change, 0 to destroy".
#
# Os recursos que continuam na raiz com o mesmo endereço
# (google_compute_instance.vm_aluno e google_compute_route.internet_explicita)
# não precisam de `moved`.

# --- Módulo vpc-network ---
moved {
  from = google_compute_network.vpc_aluno
  to   = module.vpc.google_compute_network.vpc
}

moved {
  from = google_compute_subnetwork.subnet_principal
  to   = module.vpc.google_compute_subnetwork.subnet
}

moved {
  from = google_compute_router.router_aluno
  to   = module.vpc.google_compute_router.router[0]
}

moved {
  from = google_compute_router_nat.nat_aluno
  to   = module.vpc.google_compute_router_nat.nat[0]
}

# --- Módulo firewall-rules ---
moved {
  from = google_compute_firewall.allow_ssh_iap
  to   = module.firewall.google_compute_firewall.allow_ssh_iap[0]
}

moved {
  from = google_compute_firewall.allow_internal_icmp
  to   = module.firewall.google_compute_firewall.allow_internal_icmp
}

# --- Módulo vpc-peering ---
moved {
  from = google_compute_network_peering.peering_aluno_para_hub
  to   = module.peering_hub.google_compute_network_peering.peering
}
