#!/usr/bin/env bash
# ==============================================================================
# Script de Preparação dos Projetos de Bancadas/Grupos (Até 40 Alunos = 10 Projetos)
# ==============================================================================
# COTA GCP RESPEITADA:
# - Até 4 alunos por projeto GCP (ex: einfo-redes-grupo-01 atende alunos 01 a 04).
# - Cada projeto GCP suporta até 5 VPCs simultâneas. Removendo a VPC `default`
#   e suas regras de firewall padrão, liberamos 5 slots limpos por projeto!
#
# COMO USAR ANTES DO EVENTO:
#   chmod +x scripts/setup-projetos-grupos.sh
#   BILLING_ACCOUNT_ID="XXXXXX-XXXXXX-XXXXXX" ./scripts/setup-projetos-grupos.sh

set -euo pipefail

BILLING_ACCOUNT_ID="${BILLING_ACCOUNT_ID:-}"
PROJECT_PREFIX="${PROJECT_PREFIX:-einfo-redes-grupo}"
TOTAL_GROUPS="${TOTAL_GROUPS:-10}" # 10 projetos x 4 alunos = 40 alunos

if [[ -z "$BILLING_ACCOUNT_ID" ]]; then
  echo "[ERRO] Defina a variável BILLING_ACCOUNT_ID antes de executar:"
  echo "  BILLING_ACCOUNT_ID=\"012345-6789AB-CDEF01\" ./scripts/setup-projetos-grupos.sh"
  exit 1
fi

for i in $(seq -w 1 "$TOTAL_GROUPS"); do
  PROJECT_ID="${PROJECT_PREFIX}-${i}"
  echo "=================================================================="
  echo " Preparando Projeto do Grupo ${i}: ${PROJECT_ID}"
  echo "=================================================================="

  # 1. Cria o projeto caso ainda não exista
  if ! gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
    gcloud projects create "$PROJECT_ID" --name="e-info Redes Grupo ${i}"
  fi

  # 2. Vincula a conta de faturamento (Billing Account)
  gcloud billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

  # 3. Habilita as APIs essenciais para os laboratórios (Compute Engine + Cloud IAP)
  gcloud services enable compute.googleapis.com iap.googleapis.com --project="$PROJECT_ID"

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

  echo " [OK] Projeto ${PROJECT_ID} pronto para receber até 4 alunos!"
done
