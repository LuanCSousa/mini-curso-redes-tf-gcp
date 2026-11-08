#!/usr/bin/env bash
# ==============================================================================
# Limpeza Pós-Evento — Redes.tf (FinOps)
# ==============================================================================
# 1. Remove todos os VPC Peerings `peer-hub-to-aluno-XX` das VPCs do Hub.
# 2. (Opcional) Com DELETE_PROJECTS=true, apaga os projetos de grupo inteiros
#    (VMs, NATs e VPCs esquecidas pelos alunos vão junto). Pede confirmação.
#
# O Hub em si (VPCs, VMs coletoras, NAT) deve ser removido com `terraform destroy`
# dentro de terraform/hub-facilitador/, e o mural com:
#   gcloud run services delete mural-redes-tf --region=us-central1 --project=$HUB_PROJECT_ID
#
# COMO USAR:
#   ./scripts/cleanup-pos-evento.sh
#   DELETE_PROJECTS=true ./scripts/cleanup-pos-evento.sh

set -euo pipefail

HUB_PROJECT_ID="${HUB_PROJECT_ID:-einfo-redes-hub-central}"
PROJECT_PREFIX="${PROJECT_PREFIX:-einfo-redes-grupo}"
TOTAL_GROUPS="${TOTAL_GROUPS:-10}"
DELETE_PROJECTS="${DELETE_PROJECTS:-false}"

for hub_vpc in vpc-hub-turma-a vpc-hub-turma-b; do
  peers=$(gcloud compute networks peerings list --network="$hub_vpc" --project="$HUB_PROJECT_ID" \
    --format="value(peerings.name)" 2>/dev/null | tr ';' '\n' | grep '^peer-hub-to-aluno-' || true)
  for peer in $peers; do
    echo " -> Removendo ${peer} de ${hub_vpc}..."
    gcloud compute networks peerings delete "$peer" --network="$hub_vpc" --project="$HUB_PROJECT_ID" --quiet || true
  done
done

if [[ "$DELETE_PROJECTS" == "true" ]]; then
  echo
  echo "ATENÇÃO: os projetos ${PROJECT_PREFIX}-01 a ${PROJECT_PREFIX}-$(printf %02d "$TOTAL_GROUPS") serão APAGADOS."
  read -r -p "Digite APAGAR para confirmar: " answer
  if [[ "$answer" != "APAGAR" ]]; then
    echo "Cancelado."
    exit 1
  fi
  for i in $(seq -w 1 "$TOTAL_GROUPS"); do
    project="${PROJECT_PREFIX}-${i}"
    if gcloud projects describe "$project" >/dev/null 2>&1; then
      echo " -> Apagando projeto ${project}..."
      gcloud projects delete "$project" --quiet || true
    fi
  done
fi

echo "[OK] Limpeza concluída."
