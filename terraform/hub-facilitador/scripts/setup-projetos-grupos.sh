#!/usr/bin/env bash
# ==============================================================================
# Script de Preparação dos Projetos de Bancadas/Grupos (Até 40 Alunos = 10 Projetos)
# ==============================================================================
# DISTRIBUIÇÃO:
# - Até 4 alunos por projeto GCP (grupo = ceil(student_id / 4)):
#   einfo-redes-grupo-01 -> alunos 01..04, grupo-02 -> 05..08, ..., grupo-10 -> 37..40.
# - Removemos a VPC `default` (e suas regras permissivas) para que cada projeto
#   contenha apenas as VPCs dos alunos. Confira no console (IAM & Admin > Quotas)
#   a cota "Networks" do projeto antes do evento (padrão atual: 15).
#
# IAM DOS ALUNOS (opcional, mas necessário para o dia):
# Se o arquivo scripts/students.csv existir (veja students.csv.example), o script:
#   1. Ativa o OS Login no projeto (SSH via IAP autenticado pelo IAM);
#   2. Concede a cada aluno, no projeto do SEU grupo, os papéis mínimos para os labs.
#
# COMO USAR ANTES DO EVENTO:
#   chmod +x scripts/setup-projetos-grupos.sh
#   cp scripts/students.csv.example scripts/students.csv   # e preencha (não versionar!)
#   BILLING_ACCOUNT_ID="XXXXXX-XXXXXX-XXXXXX" ./scripts/setup-projetos-grupos.sh

set -euo pipefail

BILLING_ACCOUNT_ID="${BILLING_ACCOUNT_ID:-}"
HUB_PROJECT_ID="${HUB_PROJECT_ID:-einfo-redes-hub-central}"
PROJECT_PREFIX="${PROJECT_PREFIX:-einfo-redes-grupo}"
TOTAL_GROUPS="${TOTAL_GROUPS:-10}" # 10 projetos x 4 alunos = 40 alunos
STUDENTS_CSV="${STUDENTS_CSV:-$(dirname "$0")/students.csv}"

# Papéis mínimos de cada aluno no projeto do seu grupo:
STUDENT_ROLES=(
  roles/compute.networkAdmin            # VPC, sub-rede, rotas, Cloud Router/NAT e Peering
  roles/compute.securityAdmin           # Regras de firewall
  roles/compute.instanceAdmin.v1        # VM de teste
  roles/compute.osAdminLogin            # Login SSH via OS Login
  roles/iap.tunnelResourceAccessor      # Túnel TCP do Cloud IAP (porta 22)
  roles/serviceusage.serviceUsageConsumer
)

if [[ -z "$BILLING_ACCOUNT_ID" ]]; then
  echo "[ERRO] Defina a variável BILLING_ACCOUNT_ID antes de executar:"
  echo "  BILLING_ACCOUNT_ID=\"012345-6789AB-CDEF01\" ./scripts/setup-projetos-grupos.sh"
  exit 1
fi

# Cria (se preciso) o projeto, vincula o billing e ativa Compute + IAP.
# Espera a Compute API propagar: logo após o `services enable`, comandos
# `gcloud compute` ainda falham por alguns segundos/minutos.
prepare_project() {
  local project_id="$1" display_name="$2"

  if ! gcloud projects describe "$project_id" >/dev/null 2>&1; then
    gcloud projects create "$project_id" --name="$display_name"
  fi

  gcloud billing projects link "$project_id" --billing-account="$BILLING_ACCOUNT_ID" >/dev/null
  gcloud services enable compute.googleapis.com iap.googleapis.com --project="$project_id"

  echo " -> Aguardando a Compute Engine API ficar disponível em ${project_id}..."
  for _ in $(seq 1 30); do
    gcloud compute project-info describe --project="$project_id" --format="value(name)" >/dev/null 2>&1 && return 0
    sleep 10
  done
  echo "[ERRO] Compute Engine API não ficou disponível em ${project_id} após 5 minutos."
  exit 1
}

# ------------------------------------------------------------------------------
# 0. Projeto Central (Hub): o Terraform de hub-facilitador/ é aplicado nele
# ------------------------------------------------------------------------------
echo "=================================================================="
echo " Preparando Projeto Central (Hub): ${HUB_PROJECT_ID}"
echo "=================================================================="
prepare_project "$HUB_PROJECT_ID" "e-info Redes Hub Central"

for n in $(seq 1 "$TOTAL_GROUPS"); do
  i="$(printf %02d "$n")"
  PROJECT_ID="${PROJECT_PREFIX}-${i}"
  echo "=================================================================="
  echo " Preparando Projeto do Grupo ${i}: ${PROJECT_ID}"
  echo "=================================================================="

  # 1–3. Cria o projeto, vincula o Billing e ativa Compute Engine + Cloud IAP
  prepare_project "$PROJECT_ID" "e-info Redes Grupo ${i}"

  # 4. Remove as regras de firewall padrão e a VPC `default` para liberar os 5 slots de VPC
  if gcloud compute networks describe default --project="$PROJECT_ID" >/dev/null 2>&1; then
    echo " -> Removendo regras de firewall da VPC default em ${PROJECT_ID}..."
    DEFAULT_FWS=$(gcloud compute firewall-rules list --project="$PROJECT_ID" --filter="network~default" --format="value(name)")
    for fw in $DEFAULT_FWS; do
      gcloud compute firewall-rules delete "$fw" --project="$PROJECT_ID" --quiet
    done

    echo " -> Removendo VPC default em ${PROJECT_ID} (liberando 5 VPCs para os 4 alunos do grupo)..."
    gcloud compute networks delete default --project="$PROJECT_ID" --quiet
  else
    echo " -> VPC default já foi removida em ${PROJECT_ID}."
  fi

  # 5. Ativa o OS Login (SSH autenticado pelo IAM, sem chaves em metadata de projeto)
  gcloud compute project-info add-metadata --project="$PROJECT_ID" --metadata=enable-oslogin=TRUE >/dev/null

  echo " [OK] Projeto ${PROJECT_ID} pronto para receber até 4 alunos!"
done

# ------------------------------------------------------------------------------
# 6. Concede IAM aos alunos (student_id,email,nome) no projeto do grupo de cada um
# ------------------------------------------------------------------------------
if [[ -f "$STUDENTS_CSV" ]]; then
  echo "=================================================================="
  echo " Concedendo IAM aos alunos listados em ${STUDENTS_CSV}"
  echo "=================================================================="
  tail -n +2 "$STUDENTS_CSV" | while IFS=, read -r sid email nome; do
    sid="$(echo "$sid" | tr -d '[:space:]')"
    email="$(echo "$email" | tr -d '[:space:]')"
    [[ -z "$sid" || -z "$email" ]] && continue
    group=$(( (10#$sid + 3) / 4 ))
    project="$(printf "%s-%02d" "$PROJECT_PREFIX" "$group")"
    echo " -> aluno-$(printf %02d "$((10#$sid))") (${email}) => ${project}"
    for role in "${STUDENT_ROLES[@]}"; do
      gcloud projects add-iam-policy-binding "$project" \
        --member="user:${email}" --role="$role" --condition=None --quiet </dev/null >/dev/null
    done
  done
else
  echo "[AVISO] ${STUDENTS_CSV} não encontrado: nenhum IAM de aluno foi concedido."
fi
