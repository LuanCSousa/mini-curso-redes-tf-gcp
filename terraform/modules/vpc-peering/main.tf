# ==============================================================================
# Módulo: vpc-peering — Recursos Encapsulados (modules/vpc-peering/main.tf)
# ==============================================================================

locals {
  peer_network_self_link = "projects/${var.peer_project_id}/global/networks/${var.peer_vpc_name}"
}

resource "google_compute_network_peering" "peering" {
  name                 = var.peering_name
  network              = var.local_vpc_self_link
  peer_network         = local.peer_network_self_link
  export_custom_routes = var.export_custom_routes
  import_custom_routes = var.import_custom_routes
}
