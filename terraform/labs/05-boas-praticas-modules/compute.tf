# ==============================================================================
# Carga de Trabalho Consumindo os Módulos (labs/05-boas-praticas-modules/compute.tf)
# ==============================================================================

resource "google_compute_instance" "vm_aluno" {
  name         = local.vm_name
  machine_type = "e2-micro"
  zone         = var.zone
  description  = "VM privada de diagnóstico de rede do participante ${local.student_suffix}"

  # Consome as tags padronizadas expostas pelo módulo de firewall:
  tags   = concat(module.firewall.iap_target_tags, [local.student_suffix])
  labels = local.common_labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  # Consome os outputs expostos pelo módulo de rede:
  network_interface {
    network    = module.vpc.vpc_id
    subnetwork = module.vpc.subnet_id
  }

  allow_stopping_for_update = true

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
