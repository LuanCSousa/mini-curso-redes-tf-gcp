# Infraestrutura do Projeto Central (Hub do Facilitador — Luan Sousa)

Este diretório contém toda a **Infraestrutura como Código (Terraform)** e os **Scripts Operacionais** mantidos pelo facilitador (**Luan Sousa**) para preparar as bancadas dos alunos e operar o **Projeto Central (`einfo-redes-hub-central`)** durante o minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"**.

---

## 1. Arquitetura (Suporte para até 40 Alunos)

1. **Agrupamento de Alunos em Projetos de Bancada (`scripts/setup-projetos-grupos.sh`):**
   - O script cria o **projeto do Hub** (`einfo-redes-hub-central`, onde o Terraform deste diretório é aplicado) e até **10 projetos** de grupo (`einfo-redes-grupo-01` a `10`), vincula o Billing, ativa as APIs (`compute.googleapis.com` e `iap.googleapis.com`), **remove a VPC `default`** (e suas regras permissivas) e ativa o **OS Login**.
   - Cada projeto recebe **até 4 alunos** (grupo = `ceil(student_id / 4)`), isolados pelo sufixo `aluno-XX` em todos os recursos. Isso reduz o número de projetos/billing a gerenciar e mantém folga nas cotas por projeto (redes, IPs externos do NAT, CPUs). Confira a cota **"Networks"** em *IAM & Admin > Quotas* antes do evento (padrão atual: 15 por projeto).
   - Se `scripts/students.csv` existir (copie de [`students.csv.example`](./scripts/students.csv.example)), o script também concede a cada aluno, **no projeto do seu grupo**, os papéis mínimos dos labs: `compute.networkAdmin`, `compute.securityAdmin`, `compute.instanceAdmin.v1`, `compute.osAdminLogin`, `iap.tunnelResourceAccessor` e `serviceusage.serviceUsageConsumer`.
   - > ⚠️ O IAM do GCP não isola alunos **dentro** do mesmo projeto: o isolamento entre os 4 colegas é por convenção de nomes (`aluno-XX`). Oriente a turma a só operar nos próprios recursos.
2. **Sharding das VPCs do Hub (`vpc-hub-turma-a` e `vpc-hub-turma-b`):**
   - O Google Cloud impõe o limite de **25 VPC Peerings por VPC**. Por isso, [`vpc-hub.tf`](./vpc-hub.tf) provisiona **2 VPCs de Hub** ("Turma A/B" são apenas **shards** do Hub, não turmas separadas — todos assistem à mesma aula):
     - **`vpc-hub-turma-a` (`10.0.1.0/24`):** Recebe os Peerings dos **Alunos 01 a 20**; VM coletora `vm-coletora-turma-a` em **`10.0.1.10`**.
     - **`vpc-hub-turma-b` (`10.0.2.0/24`):** Recebe os Peerings dos **Alunos 21 a 40**; VM coletora `vm-coletora-turma-b` em **`10.0.2.10`**.
3. **VMs Coletoras:** servidor HTTP na porta `80` que recebe `POST /checkin`. O **`student_id` é derivado do IP privado real de origem** (`10.<ID>.0.x`) — o payload só informa o `nome`. Origens fora de `10.1–40.0.0/24` recebem `403`. Cada VM também serve um mural próprio em `GET /`.
4. **Mural no Cloud Run (privado, criado pelo próprio Terraform):** painel unificado com os 40 cards, alimentado pelas VMs coletoras (que saem via Cloud NAT do Hub). O serviço **não aceita requisições anônimas**: as VMs se autenticam com a service account `sa-vm-coletora` (papel `roles/run.invoker`, via ID token do metadata server) e o facilitador visualiza pelo proxy autenticado do `gcloud`. Assim, ninguém na internet lê ou posta cards — o único caminho para acender um card é o VPC Peering até uma VM coletora. O Cloud Run **só exibe o mural**; o aceite dos peerings é feito pelo script local (seção 3).

---

## 2. Passo a Passo para o Facilitador (Véspera do Curso)

### Passo 1: Preparar o Projeto do Hub e os 10 Projetos dos Grupos
```bash
cd terraform/hub-facilitador
chmod +x scripts/*.sh

# (Recomendado) Lista de alunos para conceder IAM — contém e-mails, NÃO versionar (.gitignore já cobre)
cp scripts/students.csv.example scripts/students.csv
# edite scripts/students.csv: student_id,email,nome

BILLING_ACCOUNT_ID="SEU_BILLING_ACCOUNT_ID" ./scripts/setup-projetos-grupos.sh
# Para um ensaio com menos projetos (ex: conta free trial, que limita projetos com billing):
# TOTAL_GROUPS=1 BILLING_ACCOUNT_ID=... ./scripts/setup-projetos-grupos.sh
```

### Passo 2: Subir o Hub Central (VPCs, VMs Coletoras e Mural) — um único `terraform apply`
Pré-requisito: `gcloud auth login` e `gcloud auth application-default login` com a conta Owner do projeto do Hub (o build da imagem do Mural roda `gcloud builds submit` na sua máquina).

```bash
cp terraform.tfvars.example terraform.tfvars
# Edite hub_project_id (e enable_mural = false se não quiser o Cloud Run)

terraform init
terraform apply
```

O Terraform resolve a ordem sozinho pelo grafo de dependências ([`mural.tf`](./mural.tf)):
1. Ativa as APIs (Cloud Run, Artifact Registry, Cloud Build) e cria o repositório Docker `mural-redes-tf`;
2. Builda a imagem de [`mural-cloud-run/`](./mural-cloud-run) (tag = hash do código: só rebuilda quando `main.py`/`Dockerfile` mudam);
3. Publica o serviço `mural-redes-tf` **privado** (sem `allUsers`) com **exatamente 1 instância** — o estado fica em memória, então nada de scale-to-zero nem de dividir o estado;
4. Cria a service account `sa-vm-coletora` com `roles/run.invoker` **somente** nesse serviço;
5. Só então cria as VMs coletoras, já com a URL do Mural no startup script.

A URL do Cloud Run é estável: atualizar o código do mural gera uma nova revisão **sem recriar as VMs coletoras**.

> **Erro de permissão no build?** Desde 2024, o Cloud Build usa por padrão a service account padrão do Compute Engine. Se uma política da organização bloqueia os papéis automáticos dela, conceda `roles/artifactregistry.writer`, `roles/storage.objectViewer` e `roles/logging.logWriter` a `<PROJECT_NUMBER>-compute@developer.gserviceaccount.com` e rode o `apply` de novo.

#### Abrindo o Mural no projetor (com a sua conta Google)
No computador ligado ao projetor, autenticado com `gcloud auth login` (conta Owner do projeto do Hub, que já tem `run.invoker`):
```bash
$(terraform output -raw mural_proxy_cmd)
# = gcloud run services proxy mural-redes-tf --region=us-central1 --project=einfo-redes-hub-central --port=8080
```
Abra **http://localhost:8080** no navegador e coloque em tela cheia. O proxy injeta o seu token em cada requisição; feche-o com `Ctrl+C` ao final.

> Sem Cloud Run (`enable_mural = false`): cada VM coletora serve seu próprio mural na porta 80 (veja os outputs `tunnel_mural_turma_a_cmd` / `tunnel_mural_turma_b_cmd`).

### Passo 3: Ensaio Ponta a Ponta (obrigatório na véspera)
Use um `student_id` de teste (ex: `40`, num projeto de grupo) e rode o fluxo completo de um aluno:
1. `terraform apply` em `terraform/labs/04-vpc-peering-hub/` com o `student_id` de teste.
2. `./scripts/auto-accept-peerings.sh` → peering `ACTIVE` dos dois lados.
3. SSH via IAP na VM de teste → `ping -c 3 10.0.2.10` e o `curl` do output `comando_checkin_mural`.
4. Card aparece no mural (VM coletora e Cloud Run via `mural_proxy_cmd`). Confirme também que o mural está **privado**: `curl -s -o /dev/null -w '%{http_code}' "$(terraform output -raw mural_url)"` (rodado em `terraform/hub-facilitador/`) deve retornar `403`.
5. `terraform destroy` do aluno de teste.

---

## 3. Operação Durante a Etapa 04 (`15h00 – 16h05`)

Deixe o reconciliador automático rodando em uma aba do seu terminal:

```bash
./scripts/auto-accept-peerings.sh
```

A cada 15 segundos ele detecta qualquer `vpc-redes-tf-aluno-XX` nos projetos `einfo-redes-grupo-01..10` e cria o lado recíproco do VPC Peering no Hub correspondente (o estado passa a `ACTIVE`).

> ⚠️ **Escolha UM modo de aceite.** O script e a variável Terraform `active_student_peerings` (em [`peering-hub.tf`](./peering-hub.tf)) criam peerings com o mesmo nome (`peer-hub-to-aluno-XX`). Usando o script, mantenha `active_student_peerings = {}`.

---

## 4. Limpeza Pós-Evento (FinOps)

```bash
# Remove todos os peerings peer-hub-to-aluno-XX das VPCs do Hub
./scripts/cleanup-pos-evento.sh

# (Opcional) Também apaga os 10 projetos de grupo (pede confirmação digitando APAGAR)
DELETE_PROJECTS=true ./scripts/cleanup-pos-evento.sh

# Remove o Hub, o Mural no Cloud Run e o repositório da imagem
terraform destroy
```
