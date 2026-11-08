#!/usr/bin/env bash
# ==============================================================================
# Auto-Aceitação de VPC Network Peerings dos Alunos (Hub Central -> Alunos 01..40)
# ==============================================================================
# Durante a Etapa 04 (15h00–16h05), basta deixar este script rodando no terminal
# do facilitador. Ele varre os projetos dos grupos,
# detecta todas as VPCs `vpc-redes-tf-aluno-XX` recém-criadas pelos alunos e cria
# automaticamente o peering recíproco no Hub correspondente:
#   - Alunos 01 a 20 -> `vpc-hub-turma-a`
#   - Alunos 21 a 40 -> `vpc-hub-turma-b`
#
# IMPORTANTE: não use junto com `active_student_peerings` do Terraform
# (os dois criam peerings com o mesmo nome).
#
# COMO USAR:
#   chmod +x scripts/auto-accept-peerings.sh
#   ./scripts/auto-accept-peerings.sh

set -euo pipefail

HUB_PROJECT_ID="${HUB_PROJECT_ID:-einfo-redes-hub-central}"
PROJECT_PREFIX="${PROJECT_PREFIX:-einfo-redes-grupo}"
TOTAL_GROUPS="${TOTAL_GROUPS:-10}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-15}"

echo "======================================================================"
echo " Iniciando Reconciliador Automático de VPC Peering — Redes.tf"
echo " Hub Central : ${HUB_PROJECT_ID}"
echo " Intervalo   : a cada ${INTERVAL_SECONDS}s (Pressione Ctrl+C para parar)"
echo "======================================================================"

while true; do
  # Lista peerings já existentes nas duas VPCs do Hub para não recriar
  EXISTING_PEERS_A=$(gcloud compute networks peerings list --network="vpc-hub-turma-a" --project="$HUB_PROJECT_ID" --format="value(peerings.name)" 2>/dev/null | tr ';' '\n' || true)
  EXISTING_PEERS_B=$(gcloud compute networks peerings list --network="vpc-hub-turma-b" --project="$HUB_PROJECT_ID" --format="value(peerings.name)" 2>/dev/null | tr ';' '\n' || true)

  for n in $(seq 1 "$TOTAL_GROUPS"); do
    STUDENT_PROJECT="$(printf "%s-%02d" "$PROJECT_PREFIX" "$n")"

    # Verifica se o projeto do grupo existe
    if ! gcloud projects describe "$STUDENT_PROJECT" >/dev/null 2>&1; then
      continue
    fi

    # Busca todas as VPCs de alunos criadas nesse projeto (vpc-redes-tf-aluno-XX)
    STUDENT_VPCS=$(gcloud compute networks list --project="$STUDENT_PROJECT" --filter="name~^vpc-redes-tf-aluno-" --format="value(name)" 2>/dev/null || true)

    for vpc_name in $STUDENT_VPCS; do
      # Extrai o número XX do final de vpc-redes-tf-aluno-XX
      student_num_str="${vpc_name##*aluno-}"
      student_num=$((10#$student_num_str))
      peer_name=$(printf "peer-hub-to-aluno-%02d" "$student_num")

      if (( student_num <= 20 )); then
        hub_vpc="vpc-hub-turma-a"
        existing_list="$EXISTING_PEERS_A"
      else
        hub_vpc="vpc-hub-turma-b"
        existing_list="$EXISTING_PEERS_B"
      fi

      if echo "$existing_list" | grep -qx "$peer_name"; then
        continue
      fi

      echo "[NOVO PEERING DETECTADO] Aceitando ${vpc_name} (Projeto: ${STUDENT_PROJECT}) em ${hub_vpc}..."
      gcloud compute networks peerings create "$peer_name" \
        --network="$hub_vpc" \
        --peer-project="$STUDENT_PROJECT" \
        --peer-network="$vpc_name" \
        --project="$HUB_PROJECT_ID" \
        --quiet && echo " -> [ACTIVE] ${peer_name} conectado com sucesso!" || true
    done
  done

  sleep "$INTERVAL_SECONDS"
done
