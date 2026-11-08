# Roteiro Minuto a Minuto do Facilitador — Redes.tf (8h)

Este documento é o **guia de palco e condução técnica** de **Luan Sousa** para o dia do minicurso no **e-info / FACAPE**. Ele detalha o ritmo de cada bloco, a ordem exata de digitação durante o *Live Coding*, os ganchos didáticos e como destravar rapidamente qualquer aluno.

---

## Checklist da Véspera (obrigatório)

- [ ] **Projetos dos grupos e IAM:** `scripts/setup-projetos-grupos.sh` executado com `scripts/students.csv` preenchido (projetos `einfo-redes-grupo-01..10`, VPC `default` removida, OS Login ativo e papéis dos alunos concedidos).
- [ ] **Hub Central de pé (`terraform/hub-facilitador/`):** Cloud Run do mural publicado com `--min-instances=1 --max-instances=1` **antes** do `terraform apply` (URL em `mural_cloud_run_url`).
- [ ] **Ensaio ponta a ponta com um `student_id` de teste** (ex: `40`): `terraform apply` do lab 04 → `auto-accept-peerings.sh` → peering `ACTIVE` → SSH IAP → `ping 10.0.2.10` → `curl` de check-in → card no mural → `terraform destroy`.
- [ ] **Slides:** abrir `slides/index.html` offline (fontes locais) e conferir as notas do apresentador (tecla `N`).

## Checklist do Facilitador (30 min antes das 08h00)

- [ ] **Projeto Central (Hub):**
  - Confirmar que `vpc-hub-turma-a` (`10.0.1.0/24`) e `vpc-hub-turma-b` (`10.0.2.0/24`) estão ativas.
  - Confirmar que as VMs coletoras `e2-micro` (`10.0.1.10` e `10.0.2.10`) estão rodando (`systemctl status redes-tf-collector` via SSH IAP).
  - Abrir o **Mural do Cloud Run** em uma aba dedicada do navegador no computador do projetor.
- [ ] **Lista de `student_id` (`01` a `40`) e projetos de grupo:**
  - Deixar visível a tabela `student_id` → `project_id` (`einfo-redes-grupo-XX`, grupo = `ceil(ID/4)`), evitando que dois alunos usem o mesmo número.
- [ ] **Ambiente de Live Coding limpo:**
  - Abrir o VS Code na pasta `terraform/live-coding/` (vazia no início) com fonte tamanho `18px–20px` (alto contraste para o projetor).
  - Deixar uma segunda janela/aba oculta com `terraform/labs/` aberta como sua "cola" rápida dos blocos de código.

---

## TURNO DA MANHÃ (08h00 – 12h00)

### Bloco 1: Boas-vindas, Check de Ambiente e Fundamentos de Redes na Nuvem (`08h00 – 09h00`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `08h00 – 08h15` | 15m | **Boas-vindas e Apresentação:** Apresentar trajetória (FACAPE -> SantoDigital, Cloud Engineer, projetos reais). Explicar a proposta do curso: *"Hoje ninguém vai criar rede clicando em botão no painel; vamos construir como engenheiros de nuvem fazem em produção"*. |
| `08h15 – 08h25` | 10m | **Atribuição do `student_id` e Validação do Pré-material:** Garantir que cada aluno tem: (1) seu `student_id` anotado; (2) terminal aberto (local ou **Google Cloud Shell**); (3) projeto GCP do grupo configurado (`gcloud config get-value project` → `einfo-redes-grupo-XX`). |
| `08h25 – 08h45` | 20m | **Teoria Visual nos Slides (IPv4, CIDR e Sub-redes):** Explicar de forma visual como funciona a máscara `/24` (3 primeiros octetos fixos para a rede, último octeto com 256 posições para hosts) e por que no GCP perdemos 4 IPs por sub-rede (`.0`, `.1`, `.254`, `.255`), sobrando 252 IPs utilizáveis. |
| `08h45 – 09h00` | 15m | **Anatomia da VPC no Google Cloud:** Mostrar nos slides a diferença entre redes físicas tradicionais e a SDN Andromeda do GCP: **VPC é Global**, **Sub-redes são Regionais** (`us-central1`) e **VMs são Zonais** (`us-central1-a`). |

---

### Bloco 2: Introdução ao Terraform e Setup Inicial do Live Coding (`09h00 – 09h50`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `09h00 – 09h20` | 20m | **Slides de Terraform:** Explicar HCL, Providers, Resources, Variables, Locals, Outputs e o papel crítico do `terraform.tfstate`. Mostrar o fluxo `init -> plan -> apply -> destroy`. |
| `09h20 – 09h50` | 30m | **LIVE CODING — Parte 0 (Preparando a fundação em `terraform/live-coding/`):**<br/>1. Criar `versions.tf` (definindo `required_version = ">= 1.5.0"` e provider `hashicorp/google` `~> 5.0`).<br/>2. Criar `providers.tf` (configurando `project = var.project_id` e `region = var.region`).<br/>3. Criar `variables.tf` com `project_id`, `region` (default `us-central1`), `zone` (default `us-central1-a`) e `student_id` (com bloco `validation` exigindo número inteiro entre `1` e `40`).<br/>4. Criar `terraform.tfvars` local com os dados do aluno.<br/>5. Rodar `terraform init` e mostrar o download do plugin da Google em `.terraform/`. |

> **Erros comuns dos alunos neste ponto:**
> - *Erro de autenticação ADC:* pedir para rodar `gcloud auth application-default login`.
> - *API Compute Engine desabilitada:* pedir para rodar `gcloud services enable compute.googleapis.com`.

---

### Intervalo da Manhã (`09h50 – 10h10` | 20 min)
*Dica para o facilitador:* Aproveitar os primeiros 5 minutos do intervalo para caminhar pela sala e garantir que 100% dos alunos conseguiram rodar o `terraform init` com sucesso.

---

### Bloco 3: Live Coding Etapa 01 — VPC Customizada e Sub-rede Regional (`10h10 – 11h00`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `10h10 – 10h20` | 10m | **Slides Etapa 01:** Explicar `auto_create_subnetworks = false` (modo Custom vs. Auto) e mostrar como o `student_id` formará o CIDR `10.<ID>.0.0/24`. |
| `10h20 – 10h45` | 25m | **LIVE CODING — Etapa 01 (Referência: `labs/01-vpc-subnets/`):**<br/>1. Criar `locals.tf`: montar `subnet_cidr = "10.${var.student_id}.0.0/24"` e `student_suffix = format("aluno-%02d", var.student_id)`.<br/>2. Criar `vpc.tf`: escrever o `resource "google_compute_network" "vpc_aluno"` e em seguida o `resource "google_compute_subnetwork" "subnet_principal"`, demonstrando a referência implícita `network = google_compute_network.vpc_aluno.id` (Grafo de Dependências do Terraform!).<br/>3. Criar `outputs.tf` exibindo `vpc_name`, `subnet_cidr` e `subnet_gateway_ip` (atributo `gateway_address`). |
| `10h45 – 11h00` | 15m | **Execução e Inspeção:**<br/>1. Rodar `terraform fmt`, `terraform validate` e `terraform plan` (ler o plano com a turma: `Plan: 2 to add, 0 to change, 0 to destroy`).<br/>2. Rodar `terraform apply`.<br/>3. Abrir o Console GCP -> *VPC Network* e mostrar a VPC e a Sub-rede criadas pelo código! |

> **Checkpoint 01:** Se algum aluno teve erro de digitação, ele pode copiar os arquivos prontos de `terraform/labs/01-vpc-subnets/`.

---

### Bloco 4: Live Coding Etapa 02 — Firewall Stateful, IAP e VM Privada (`11h00 – 12h00`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `11h00 – 11h20` | 20m | **Slides Etapa 02:** Explicar Firewall Stateful no GCP, Ingress vs. Egress, prioridades, Network Tags e como o **Cloud IAP (`35.235.240.0/20`)** permite entrar via SSH numa VM que não possui IP público! |
| `11h20 – 11h45` | 25m | **LIVE CODING — Etapa 02 (Referência: `labs/02-firewall-vms/`):**<br/>1. Criar `firewall.tf`: escrever a regra `allow_ssh_iap` (liberando `tcp:22` de `35.235.240.0/20` para a tag `ssh-iap`) e a regra `allow_internal_icmp` (liberando `icmp` apenas da própria sub-rede). Perguntar: *"vamos precisar abrir algo para falar com o Hub à tarde?"* → não, o firewall é *stateful*.<br/>2. Criar `compute.tf`: escrever o `resource "google_compute_instance" "vm_aluno"` (`e2-micro`, Debian 12, conectada na sub-rede do aluno, com `tags = ["ssh-iap", local.student_suffix]` e **sem bloco `access_config`** para ficar 100% privada).<br/>3. Adicionar no `outputs.tf` o comando pronto de SSH via IAP (`gcloud compute ssh ... --tunnel-through-iap`). |
| `11h45 – 12h00` | 15m | **Execução e o Gancho Dramático para o Almoço:**<br/>1. Rodar `terraform apply`.<br/>2. Copiar o comando do `output` e entrar via SSH na VM privada!<br/>3. Pedir para todos rodarem dentro da VM: `ip a` (ver o IP `10.<ID>.0.2`) e depois `ping -c 3 8.8.8.8`.<br/>4. **Resultado:** `100% packet loss`! Perguntar à turma: *"Nossa VM está dentro da nuvem do Google, mas não consegue acessar a internet. Por quê? Na volta do almoço vamos resolver isso com Roteamento e Cloud NAT!"* |

---

## INTERVALO DE ALMOÇO (12h00 – 14h00)

---

## TURNO DA TARDE (14h00 – 18h00)

### Bloco 5: Live Coding Etapa 03 — Tabelas de Roteamento, Cloud Router e Cloud NAT (`14h00 – 15h00`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `14h00 – 14h20` | 20m | **Slides Etapa 03:** Mostrar que a VPC já tem uma rota `0.0.0.0/0` apontando para o *Default Internet Gateway*, mas a VM só tem IP privado RFC 1918 (`10.<ID>.0.2`): sem IP público de origem, o GCP não entrega o pacote à internet. Explicar o conceito de **SNAT** e como o **Cloud Router + Cloud NAT** resolvem isso sem expor a VM. |
| `14h20 – 14h45` | 25m | **LIVE CODING — Etapa 03 (Referência: `labs/03-roteamento-nat/`):**<br/>1. Criar `routes.tf`: `resource "google_compute_route" "internet_explicita"` (`0.0.0.0/0` → `default-internet-gateway`, `priority = 900`, `tags = [local.student_suffix]`). `terraform apply` e `$(terraform output -raw routes_list_command)` para ler destino / next-hop / prioridade. Na VM: `ping 8.8.8.8` **ainda falha** → rota ≠ NAT.<br/>2. Criar `nat.tf`: declarar o `resource "google_compute_router" "router_aluno"` na VPC do aluno e o `resource "google_compute_router_nat" "nat_aluno"` vinculado ao router, usando `nat_ip_allocate_option = "AUTO_ONLY"` e `source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"`.<br/>3. Rodar `terraform plan` e `terraform apply`. |
| `14h45 – 15h00` | 15m | **Validação Real na VM:**<br/>1. Voltar ao SSH da VM privada e rodar `ping -c 3 8.8.8.8` -> **Agora responde!**<br/>2. Rodar `curl -s ifconfig.me ; echo` -> Mostrar que a VM sai para a internet usando o IP público do Cloud NAT, mas ninguém de fora consegue iniciar conexão para ela! |

> **Checkpoint 03:** Quem precisar alinhar o código após o almoço pode usar `terraform/labs/03-roteamento-nat/`.

---

### Bloco 6: Live Coding Etapa 04 — VPC Peering com o Projeto Central e Desafio do Mural (`15h00 – 16h05`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `15h00 – 15h20` | 20m | **Slides Etapa 04:** Explicar arquitetura **Hub-and-Spoke** e **VPC Network Peering**. Destacar por que cada aluno recebeu um `student_id` (para que `10.1.0.0/24`, `10.2.0.0/24`... não conflitem entre si nem com o Hub `10.0.1.0/24` / `10.0.2.0/24`), o limite de 25 peerings por VPC (por isso 2 VPCs de Hub) e o aperto de mão bilateral (Peering no Aluno <-> Peering no Hub). **Iniciar `./scripts/auto-accept-peerings.sh` no seu terminal.** |
| `15h20 – 15h45` | 25m | **LIVE CODING — Etapa 04 (Referência: `labs/04-vpc-peering-hub/`):**<br/>1. Adicionar as variáveis `hub_project_id` e `student_name` no `variables.tf` e, no `locals.tf`, a condicional `is_turma_a = var.student_id <= 20` que escolhe `hub_vpc_name`, `hub_target_ip` e `hub_vpc_self_link`.<br/>2. Criar `peering.tf`: declarar `resource "google_compute_network_peering" "peering_aluno_para_hub"` com `peer_network = local.hub_vpc_self_link`.<br/>3. Rodar `terraform apply`. O estado fica `INACTIVE` até o script do Hub criar o lado recíproco (≈15 s); depois `terraform apply -refresh-only` mostra `ACTIVE`. |
| `15h45 – 16h05` | 20m | **O Momento *Aha!* — Check-in no Mural Central (Cloud Run + `10.0.1.10` / `10.0.2.10`):**<br/>1. Colocar o **Mural do Cloud Run** em tela cheia no projetor.<br/>2. Pedir para os alunos rodarem `$(terraform output -raw peering_routes_command)` (ou Console → *Routes* → *Effective routes*): a rota `10.0.1.0/24` (ou `10.0.2.0/24`) do Hub apareceu automaticamente via Peering!<br/>3. De dentro da VM privada de cada aluno (via SSH IAP), rodar:<br/>`ping -c 3 10.0.1.10` (alunos 21–40: `10.0.2.10`)<br/>e em seguida o comando de check-in copiado do output `comando_checkin_mural`:<br/>`curl -s -X POST http://10.0.1.10/checkin -H 'Content-Type: application/json' -d '{"student_id": 7, "nome": "Seu Nome", "subnet": "10.7.0.0/24"}'`<br/>(o coletor identifica o aluno pelo IP de origem; do JSON só usa o `nome`)<br/>4. Comemorar conforme os cards de cada aluno vão acendendo ao vivo no projetor! |

---

### Intervalo da Tarde (`16h05 – 16h25` | 20 min)

---

### Bloco 7: Live Coding Etapa 05 — Boas Práticas com Módulos do Terraform (`16h25 – 17h30`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `16h25 – 16h45` | 20m | **Slides Etapa 05:** Mostrar como times de Cloud Engineering na SantoDigital e grandes empresas organizam Terraform em produção. Explicar anatomia de um módulo (`variables.tf`, `main.tf`, `outputs.tf`), reutilização entre `dev/staging/prod` e versionamento semântico. |
| `16h45 – 17h30` | 45m | **DEMONSTRAÇÃO GUIADA (Código Pré-construído) — Etapa 05 (`labs/05-boas-praticas-modules/` e `terraform/modules/`):**<br/>1. Explicar que, pelo tempo enxuto, você já deixou toda a refatoração pronta no repositório como presente/material de referência pós-curso para eles.<br/>2. Abrir a pasta `terraform/modules/` no projetor e caminhar pelo código mostrando como `vpc.tf`, `nat.tf`, `firewall.tf` e `peering.tf` foram encapsulados nos 3 módulos: `vpc-network`, `firewall-rules` e `vpc-peering`.<br/>3. Abrir `labs/05-boas-praticas-modules/main.tf` e mostrar como 150 linhas de recursos brutos viram chamadas `module` limpas e padronizadas.<br/>4. Rodar `terraform init` e `terraform plan` dentro da Etapa 05 no projetor para demonstrar os módulos em ação.<br/>5. **Grand finale — `moved {}`:** copiar o `terraform.tfstate` e o `terraform.tfvars` do seu `live-coding/` para a Etapa 05 e rodar `terraform plan`: só *"has moved to"* e `0 to add, 0 to change, 0 to destroy`. A rede viva passou a ser gerenciada por módulos sem recriar nada (depois disso, faça o `destroy` a partir da Etapa 05). |

---

### Bloco 8: FinOps (`terraform destroy`), Revisão Geral e Encerramento (`17h30 – 18h00`)

| Horário | Tempo | Atividade / O que fazer no palco |
| :---: | :---: | :--- |
| `17h30 – 17h45` | 15m | **Limpeza Consciente (`terraform destroy`):** Explicar a importância de não deixar recursos órfãos na nuvem e rodar `terraform destroy` junto com os alunos (em `live-coding/`), observando a ordem reversa de destruição. Após o evento: `scripts/cleanup-pos-evento.sh` no Hub. |
| `17h45 – 18h00` | 15m | **Encerramento, Dicas de Carreira e Foto Oficial:** Revisar toda a jornada das 8h, compartilhar links do repositório GitHub, LinkedIn e tirar a foto oficial da turma com o Mural do minicurso no telão! |
