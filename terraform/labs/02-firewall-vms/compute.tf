# ==============================================================================
# Instância de VM 100% Privada de Teste (labs/02-firewall-vms/compute.tf)
# ==============================================================================
# CONCEITO DE SEGURANÇA EM REDES CLOUD:
# Em ambientes corporativos reais, servidores de aplicação e bancos de dados
# NUNCA possuem IP Público diretamente atrelado à interface de rede.
# No Terraform, basta declarar o bloco `network_interface` SEM o sub-bloco
# `access_config {}` para que a VM nasça 100% privada!

resource "google_compute_instance" "vm_aluno" {
  name         = local.vm_name
  machine_type = "e2-micro"
  zone         = var.zone
  description  = "VM privada de diagnóstico de rede do participante ${local.student_suffix}"

  # Network Tags: conectam esta VM à regra de firewall `allow_ssh_iap`
  tags = ["ssh-iap", local.student_suffix]

  labels = local.common_labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  # Interface de Rede conectada à Sub-rede Regional do Aluno:
  network_interface {
    network    = google_compute_network.vpc_aluno.id
    subnetwork = google_compute_subnetwork.subnet_principal.id

    # OBSERVAÇÃO DIDÁTICA CRUCIAL:
    # Não declaramos o bloco `access_config {}` aqui!
    # Isso garante que a VM receba APENAS um IP interno privado (10.<ID>.0.2)
    # e nenhum IP público externo.
  }

  # Permite que o Terraform altere tipo de máquina/tags se necessário
  allow_stopping_for_update = true

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
