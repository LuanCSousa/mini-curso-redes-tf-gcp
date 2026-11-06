# Infraestrutura do Projeto Central (Hub do Facilitador — Luan Sousa)

Este diretório contém toda a **Infraestrutura como Código (Terraform)** e os **Scripts Operacionais** mantidos pelo facilitador (**Luan Sousa**) para preparar as bancadas dos alunos e operar o **Projeto Central (`einfo-redes-hub-central`)** durante o minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"**.

---

## 1. Arquitetura de Engenharia de Cotas (Suporte para até 40 Alunos)

Para contornar os limites padrão de contas Google Cloud sem depender de aumento de cota pelo suporte:

1. **Agrupamento de Alunos em Projetos de Bancada (`scripts/setup-projetos-grupos.sh`):**
   - Cada projeto GCP comporta até **5 VPCs** simultâneas.
   - O script [`scripts/setup-projetos-grupos.sh`](./scripts/setup-projetos-grupos.sh) cria até **10 projetos** (`einfo-redes-grupo-01` a `10`), vincula o Billing, ativa as APIs (`compute.googleapis.com` e `iap.googleapis.com`) e **remove a VPC `default`**, liberando os 5 slots de VPC para que **4 alunos por projeto** trabalhem com isolamento total (`student_id` de `1` a `40`).
2. **Sharding das VPCs do Hub (`vpc-hub-turma-a` e `vpc-hub-turma-b`):**
   - O Google Cloud impõe o limite máximo de **25 VPC Peerings ativos por VPC**.
   - Por isso, o arquivo [`vpc-hub.tf`](./vpc-hub.tf) provisiona **2 VPCs de Hub** independentes:
     - **`vpc-hub-turma-a` (`10.0.1.0/24`):** Recebe os Peerings dos **Alunos 01 a 20** e hospeda a VM coletora `vm-coletora-turma-a` no IP fixo **`10.0.1.10`**.
     - **`vpc-hub-turma-b` (`10.0.2.0/24`):** Recebe os Peerings dos **Alunos 21 a 40** e hospeda a VM coletora `vm-coletora-turma-b` no IP fixo **`10.0.2.10`**.

---

## 2. Passo a Passo para o Facilitador Antes do Evento

### Passo 1: Preparar os 10 Projetos dos Grupos (Véspera do Curso)
```bash
cd terraform/hub-facilitador
chmod +x scripts/*.sh

# Cria einfo-redes-grupo-01..10, habilita APIs e remove a VPC default
BILLING_ACCOUNT_ID="SEU_BILLING_ACCOUNT_ID" ./scripts/setup-projetos-grupos.sh
```

### Passo 2: Subir o Hub Central (`vpc-hub-turma-a`, `vpc-hub-turma-b` e VMs Coletoras)
```bash
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars se desejar alterar o hub_project_id

terraform init
terraform apply
```

### Passo 3 (Opcional): Publicar o Mural Unificado (40 Cards) no Cloud Run
```bash
gcloud run deploy mural-redes-tf \
  --source=./mural-cloud-run \
  --region=us-central1 \
  --project=einfo-redes-hub-central \
  --allow-unauthenticated
```
*(Se preferir nem usar Cloud Run, cada VM coletora já possui seu próprio Mural Web embutido na porta 80! Basta abrir os comandos `tunnel_mural_turma_a_cmd` e `tunnel_mural_turma_b_cmd` exibidos no `terraform output`!).*

---

## 3. Operação Durante a Etapa 04 (Aceitação Automática de Peerings)

Quando a turma iniciar a **Etapa 04 (`15h25`)**, deixe o reconciliador automático rodando em uma aba do seu terminal:

```bash
./scripts/auto-accept-peerings.sh
```

A cada 15 segundos ele detecta automaticamente qualquer `vpc-redes-tf-aluno-XX` criada pelos alunos nos projetos `einfo-redes-grupo-01..10` e fecha o lado recíproco do VPC Peering no Hub correspondente (`ACTIVE`)!
