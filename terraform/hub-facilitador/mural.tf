# ==============================================================================
# Acesso Autenticado ao Mural no Cloud Run (hub-facilitador/mural.tf)
# ==============================================================================
# O Mural é publicado SEM acesso público (`--no-allow-unauthenticated`):
#   - As VMs coletoras chamam POST /api/checkin com um ID token da service account
#     abaixo, que recebe apenas o papel roles/run.invoker no serviço do Mural.
#   - O facilitador visualiza o Mural pelo proxy autenticado do gcloud
#     (output `mural_proxy_cmd`), usando a própria conta Google (Owner do projeto).
# Resultado: ninguém na internet consegue ler ou postar cards no Mural; o único
# caminho para acender um card é passar pelo VPC Peering até uma VM coletora.

resource "google_service_account" "coletora" {
  account_id   = "sa-vm-coletora"
  display_name = "VMs coletoras do Hub (invocam o Mural no Cloud Run)"
}

# Só cria a permissão se o Mural já foi publicado (Passo 2 do README do hub).
resource "google_cloud_run_v2_service_iam_member" "coletora_invoker" {
  count = var.mural_cloud_run_url != "" ? 1 : 0

  project  = var.hub_project_id
  location = var.region
  name     = var.mural_service_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.coletora.email}"
}
