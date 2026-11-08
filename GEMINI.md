# GEMINI.md — Diretrizes e Contexto do Repositório

Este arquivo define o contexto completo, a metodologia pedagógica, a arquitetura técnica e os padrões de construção do minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"**. Todas as interações para criação de ementa, slides, pré-material e códigos Terraform devem seguir rigorosamente estas diretrizes.

---

## 1. Contexto do Evento e Minicurso

- **Título Oficial:** Redes.tf: da Teoria à Prática com Terraform e GCP
- **Evento / Instituição:** **e-info** — **FACAPE** (Faculdade de Ciências Aplicadas e Sociais de Petrolina)
- **Facilitador:** **Luan Sousa**
  - Cloud Engineer na **SantoDigital** (parceira Google Cloud), atuando no desenho, implantação e sustentação de infraestrutura em nuvem.
  - Experiência em projetos de Fullstack, DevOps, Infraestrutura e SecOps.
  - Certificado **Google Cloud Digital Leader** e bacharelando em **Ciência da Computação pela FACAPE**.
- **Carga Horária e Formato:** **8 horas** em **1 dia intensivo** (Turno da Manhã: `08h00–12h00` | Turno da Tarde: `14h00–18h00`, com 20 min de intervalo em cada turno).
- **Modalidade:** 100% prática, com laboratório real no **Google Cloud Platform (GCP)** e **Terraform**.
- **Público-alvo:** Todos os níveis (desde estudantes que viram redes apenas na teoria acadêmica até profissionais que desejam aprender IaC e Cloud Networking).

---

## 2. Metodologia de Ensino: *Live Coding* (Do Zero ao Fim) + Guia/Gabarito

1. **Construção do Zero ao Fim (*Live Coding*):**
   - Durante o minicurso, o facilitador (Luan Sousa) e os alunos **construirão toda a infraestrutura em tempo real, do zero ao fim**, dentro do diretório `terraform/live-coding/`.
   - O objetivo é que o participante entenda o **porquê** de cada componente de rede e de cada bloco HCL antes de executá-lo, evitando "copiar e colar cego".
2. **Papel das Pastas `terraform/labs/` e `terraform/modules/`:**
   - Embora os arquivos já existam prontos nessas pastas, eles **não são apenas código estático**: eles funcionam como o **Roteiro/Cola Guiada do Facilitador** durante a aula e como **Checkpoints/Gabarito** para qualquer aluno que se atrase ou queira revisar após o evento.
   - Todo laboratório criado em `terraform/labs/` deve conter:
     - Código Terraform amplamente comentado em português, conectando o recurso cloud ao conceito clássico de Redes de Computadores (ex: CIDR, tabela de roteamento, firewall stateful, SNAT, BGP/Peering).
     - Um arquivo `README.md` estruturado como **Guia de Construção Passo a Passo** (qual arquivo criar primeiro, o que explicar em cada bloco, quais comandos `terraform` rodar e como validar no Console GCP / terminal).

---

## 3. Arquitetura Técnica do Laboratório (Hub-and-Spoke no GCP)

### 3.1. Projetos dos Alunos (Agrupados em Bancadas/Grupos) + Projeto Central (Hub)
- **Projetos dos Alunos (Spokes):** Para respeitar o limite de criação de projetos da conta GCP e manter folga nas cotas por projeto (redes VPC — confirmar a cota "Networks" no console, padrão atual 15 —, IPs externos do Cloud NAT e CPUs), os alunos são distribuídos em projetos de grupo (até **4 alunos por projeto**, grupo = `ceil(student_id / 4)`, `einfo-redes-grupo-01` a `10`, suportando até 40 alunos com apenas 10 projetos). O script `terraform/hub-facilitador/scripts/setup-projetos-grupos.sh` cria os projetos, remove a VPC `default`, ativa o OS Login e — a partir de `scripts/students.csv` (não versionado) — concede a cada aluno os papéis mínimos no projeto do seu grupo (`compute.networkAdmin`, `compute.securityAdmin`, `compute.instanceAdmin.v1`, `compute.osAdminLogin`, `iap.tunnelResourceAccessor`, `serviceusage.serviceUsageConsumer`). Dentro de um mesmo projeto, o isolamento entre alunos é por convenção: todos os recursos levam o sufixo `aluno-XX`.
- **Projeto Central do Facilitador (Hub):** Mantido por Luan Sousa (`terraform/hub-facilitador/`), contendo **2 VPCs de Hub** (`vpc-hub-turma-a` `10.0.1.0/24` para alunos `01–20` e `vpc-hub-turma-b` `10.0.2.0/24` para alunos `21–40`, respeitando o limite de 25 VPC Peerings por VPC do GCP), VMs coletoras leves `e2-micro` (`10.0.1.10` e `10.0.2.10`) que respondem a `ping` e `curl` privado via **VPC Network Peering** (identificando o aluno pelo IP privado real de origem `10.<ID>.0.x`), e um serviço no **Cloud Run** (fixado em 1 instância, pois guarda estado em memória) que **apenas exibe o Mural ao vivo** no projetor. O lado do Hub de cada peering é criado pelo script local `scripts/auto-accept-peerings.sh` (ou, alternativamente e nunca junto, pela variável Terraform `active_student_peerings`). "Turma A/B" são apenas *shards* do Hub, não turmas separadas.

### 3.2. Convenção de Endereçamento IP (Prevenção de Conflito de CIDR no Peering)
Para que até 40 alunos possam compartilhar projetos (4 VPCs por projeto) e fazer **VPC Peering** simultaneamente com o Projeto Central sem sobreposição de IPs (*CIDR overlap*), **todo código Terraform dos alunos deve utilizar a variável `student_id`**:

- **VPCs do Projeto Central (Hub):**
  - `vpc-hub-turma-a` (`10.0.1.0/24` — VM coletora `10.0.1.10`) -> para `student_id` de `1` a `20`
  - `vpc-hub-turma-b` (`10.0.2.0/24` — VM coletora `10.0.2.10`) -> para `student_id` de `21` a `40`
- **ID do Aluno (`var.student_id`):** Número inteiro de `1` a `40` atribuído a cada participante antes do curso.
- **Sub-rede Principal do Aluno:** `10.${var.student_id}.0.0/24` (ex: Aluno `07` -> `10.7.0.0/24`).
- **Nomenclatura Obrigatória de Recursos:** Todos os recursos devem conter o sufixo formatado `aluno-XX` (ex: `vpc-redes-tf-aluno-07`, `subnet-us-central1-aluno-07`, `vm-teste-aluno-07`) para garantir isolamento total entre os 4 alunos do mesmo projeto GCP e identificação no Hub Central.

---

## 4. Progressão Pedagógica do Terraform (Recursos Nativos -> Módulos)

O ensino de Terraform no minicurso é dividido em duas fases intencionais:

### Fase 1: Recursos Explícitos (`terraform/labs/01` a `04`)
Nos primeiros laboratórios, **não esconda a complexidade atrás de módulos prontos**. Utilize recursos nativos do provider `hashicorp/google` (`~> 5.0`, travado por `.terraform.lock.hcl` versionado em cada raiz; Terraform `>= 1.5`) organizados de forma limpa em:
- `versions.tf` / `providers.tf`
- `variables.tf` e `locals.tf`
- `main.tf` (ou separados por contexto: `vpc.tf`, `firewall.tf`, `routes.tf`, `nat.tf`, `compute.tf`, `peering.tf`)
- `outputs.tf`
- `terraform.tfvars.example`

**Sequência evolutiva dos Labs:**
1. **`01-vpc-subnets/`:** Criação da VPC em modo custom (`auto_create_subnetworks = false`) e sub-rede regional com CIDR dinâmico baseado em `var.student_id`.
2. **`02-firewall-vms/`:** Regras de Firewall mínimas (`google_compute_firewall` para SSH via IAP e ICMP da própria sub-rede — o firewall *stateful* dispensa regras para respostas, inclusive do Hub), Network Tags e subida de VM de teste sem IP externo.
3. **`03-roteamento-nat/`:** Tabela de rotas com uma rota estática explícita (`google_compute_route` `0.0.0.0/0` → `default-internet-gateway`, prioridade 900, por network tag), `google_compute_router` e `google_compute_router_nat` (Cloud NAT) permitindo que VMs privadas acessem a internet com segurança (rota ≠ NAT).
4. **`04-vpc-peering-hub/`:** `google_compute_network_peering` conectando a VPC do aluno à VPC Central do facilitador e testando conectividade privada ponta a ponta (`ping` / `curl` interno).

### Fase 2: Boas Práticas com Módulos (`terraform/labs/05-boas-praticas-modules/` + `terraform/modules/`)
Após o aluno dominar os recursos nativos e ver sua rede funcionando:
5. **`05-boas-praticas-modules/` (Demonstração Pré-construída, `16h25–17h30`: 20 min de conceito + 45 min de demonstração):** Como o tempo final de aula é enxuto para refatorar tudo do zero, esta etapa já fica **100% pré-construída** no repositório para o facilitador demonstrar e explicar na tela como organizar o código em **Módulos Reutilizáveis** (`terraform/modules/vpc-network`, `terraform/modules/firewall-rules`, `terraform/modules/vpc-peering`), fornecendo o material pronto para os alunos utilizarem após o curso:
   - Encapsulamento e responsabilidade única de cada módulo.
   - Contratos claros de entrada (`variables.tf` com `type`, `description` e `validation`) e saída (`outputs.tf`).
   - Reaproveitamento para múltiplos ambientes (`dev`, `staging`, `prod`) via `envs/*.tfvars.example`.
   - Refatoração sem downtime com blocos `moved {}` (`moved.tf`): nomes e descrições idênticos aos do live-coding, de modo que copiar o state da aula para a Etapa 05 resulta em `0 to add, 0 to change, 0 to destroy`.

---

## 5. Cronograma Oficial

A fonte da verdade dos horários é `docs/ementa/ementa-completa.md` (Manhã: Módulos 1–4, intervalo `09h50–10h10`; Tarde: Etapa 03 `14h00–15h00`, Etapa 04 `15h00–16h05`, intervalo `16h05–16h25`, Etapa 05 `16h25–17h30`, encerramento `17h30–18h00`). READMEs dos labs, roteiro, scripts e slides devem segui-la.

---

## 6. Estrutura de Pastas do Repositório

```text
mini-curso-redes-tf-gcp/
├── GEMINI.md                        # Este arquivo de diretrizes e contexto
├── README.md                        # Apresentação principal do repositório
├── docs/                            # Documentação executiva e pedagógica
│   ├── Ficha do Mini Curso.md       # Ficha oficial submetida ao e-info (FACAPE)
│   ├── Foto Perfil.jpeg             # Foto oficial do facilitador (Luan Sousa)
│   ├── LOGO E-INFO.png              # Logo oficial do evento e-info 2026
│   ├── logo-facape.svg              # Logo oficial da FACAPE (usar nos slides e docs)
│   └── ementa/                      # Cronograma detalhado das 8h (Manhã/Tarde) e roteiro de aula
├── pre-material/                    # Guia e código de preparação prévia (Foundation)
│   └── foundation-check/            # Validação de ferramentas, auth gcloud e projeto inicial
├── terraform/                       # Todo o código de Infraestrutura como Código
│   ├── live-coding/                 # Workspace limpo para construção do zero durante a aula
│   ├── labs/                        # Etapas 01 a 05 (Guia do facilitador e checkpoints dos alunos)
│   ├── modules/                     # Módulos reutilizáveis ensinados na Etapa 05
│   └── hub-facilitador/             # Infraestrutura central (Hub), mural Cloud Run e scripts (setup, auto-accept, cleanup)
└── slides/                          # Apresentações visuais do curso
    ├── assets/                      # Imagens, diagramas e logos
    ├── 01-manha-teoria-base/        # Apresentação Web Visual — Turno da Manhã (4h)
    ├── 02-tarde-pratica-avancada/   # Apresentação Web Visual — Turno da Tarde (4h)
    └── exportados/                  # Versões em .pptx e .pdf prontas para download/backup
```

---

## 7. Diretrizes para Criação dos Slides (`slides/`)

- **Formato Principal:** **Apresentação Web Visual Interativa (16:9)** que roda diretamente no navegador em tela cheia (`F11`), **100% offline** (fontes locais em `slides/assets/fonts/`), com animações didáticas de fluxo de pacotes/redes, *syntax highlighting* para código Terraform/CLI, notas do apresentador (`<aside class="notes">` em cada slide, tecla `N`) e navegação fluida por teclado.
- **Exportação Garantida:** O HTML é a **única fonte**: `slides/generate_exports.js` (Playwright) captura cada slide e gera **PDF e PowerPoint (`.pptx`, com as notas do apresentador)** em `slides/exportados/`. Nunca redigitar conteúdo de slide no script de exportação.
- **Identidade Visual:**
  - Utilizar a logo da FACAPE (`docs/logo-facape.svg`), a logo do evento e-info (`docs/LOGO E-INFO.png` / `slides/assets/logo-einfo.png`) e a foto do facilitador (`docs/Foto Perfil.jpeg` / `slides/assets/foto-perfil.jpeg`), combinadas com a paleta moderna de **Google Cloud** (azul/verde/amarelo/vermelho) e **HashiCorp Terraform** (roxo `#7B42BC` / dark mode técnico para blocos de código).
  - Intercalar slides conceituais visuais (diagramas de sub-rede, firewall, NAT, Peering) com slides de chamada para **"Mão na Massa / Live Coding"**.
