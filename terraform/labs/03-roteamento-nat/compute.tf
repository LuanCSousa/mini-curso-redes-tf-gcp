# ==============================================================================
# Instância de VM 100% Privada de Teste (labs/03-roteamento-nat/compute.tf)
# ==============================================================================

resource "google_compute_instance" "vm_aluno" {
  name         = local.vm_name
  machine_type = "e2-micro"
  zone         = var.zone
  description  = "VM privada de diagnóstico de rede do participante ${local.student_suffix}"

  tags   = ["ssh-iap", local.student_suffix]
  labels = local.common_labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_aluno.id
    subnetwork = google_compute_subnetwork.subnet_principal.id
  }

  allow_stopping_for_update = true

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
