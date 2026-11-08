# ==============================================================================
# Mural ao Vivo no Cloud Run — privado (hub-facilitador/mural.tf)
# ==============================================================================
# Tudo do Mural sai daqui, num único `terraform apply`:
#   1. APIs (Cloud Run, Artifact Registry, Cloud Build);
#   2. Repositório Docker no Artifact Registry;
#   3. Build da imagem a partir de ./mural-cloud-run (via `gcloud builds submit`,
#      porque o Terraform não builda containers). A tag é o hash do código: só
#      rebuilda quando main.py/Dockerfile mudam;
#   4. Serviço Cloud Run com exatamente 1 instância (o estado fica em memória);
#   5. Permissão run.invoker SOMENTE para a service account das VMs coletoras.
#
# A URL do serviço é passada às VMs coletoras por referência
# (google_cloud_run_v2_service.mural[0].uri), então o grafo do Terraform garante
# a ordem: o Mural sobe antes das VMs. A URL é estável entre deploys da imagem,
# então atualizar o mural NÃO recria as VMs.
#
# Acesso: o serviço NÃO tem `allUsers` como invoker. As VMs coletoras chamam
# POST /api/checkin com um ID token da `sa-vm-coletora`; o facilitador visualiza
# pelo proxy autenticado do gcloud (output `mural_proxy_cmd`). Ninguém na
# internet lê ou posta cards — o único caminho é o VPC Peering até uma coletora.

locals {
  mural_source_dir = "${path.module}/mural-cloud-run"
  mural_source_hash = sha256(join("", [
    filesha256("${local.mural_source_dir}/main.py"),
    filesha256("${local.mural_source_dir}/Dockerfile"),
  ]))
  mural_image = "${var.region}-docker.pkg.dev/${var.hub_project_id}/mural-redes-tf/mural:${substr(local.mural_source_hash, 0, 12)}"
}

# Identidade das VMs coletoras (existe mesmo sem mural: é a SA anexada às VMs).
resource "google_service_account" "coletora" {
  account_id   = "sa-vm-coletora"
  display_name = "VMs coletoras do Hub (invocam o Mural no Cloud Run)"
}

resource "google_project_service" "mural" {
  for_each = var.enable_mural ? toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
  ]) : toset([])

  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "mural" {
  count = var.enable_mural ? 1 : 0

  location      = var.region
  repository_id = "mural-redes-tf"
  description   = "Imagem do Mural ao Vivo (Redes.tf)"
  format        = "DOCKER"
  labels        = local.common_labels

  depends_on = [google_project_service.mural]
}

# Build e push da imagem. Requer `gcloud` autenticado na máquina do facilitador.
resource "terraform_data" "mural_image" {
  count = var.enable_mural ? 1 : 0

  triggers_replace = [local.mural_image]

  provisioner "local-exec" {
    command = "gcloud builds submit '${local.mural_source_dir}' --tag='${local.mural_image}' --project='${var.hub_project_id}' --quiet"
  }

  depends_on = [google_artifact_registry_repository.mural]
}

# Identidade do próprio serviço do Mural: sem nenhum papel (ele não chama APIs).
resource "google_service_account" "mural" {
  count = var.enable_mural ? 1 : 0

  account_id   = "sa-mural-redes-tf"
  display_name = "Runtime do Mural no Cloud Run (sem papéis)"
}

resource "google_cloud_run_v2_service" "mural" {
  count = var.enable_mural ? 1 : 0

  name     = var.mural_service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  labels   = local.common_labels

  template {
    service_account = google_service_account.mural[0].email

    # O mural guarda os check-ins em memória: exatamente 1 instância,
    # sem scale-to-zero e sem dividir o estado entre instâncias.
    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }

    containers {
      image = local.mural_image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }

  depends_on = [
    google_project_service.mural,
    terraform_data.mural_image,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "coletora_invoker" {
  count = var.enable_mural ? 1 : 0

  project  = google_cloud_run_v2_service.mural[0].project
  location = google_cloud_run_v2_service.mural[0].location
  name     = google_cloud_run_v2_service.mural[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.coletora.email}"
}
