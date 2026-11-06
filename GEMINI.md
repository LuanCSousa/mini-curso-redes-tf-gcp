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
- **Projetos dos Alunos (Spokes):** Para respeitar o limite de criação de projetos da conta GCP e o limite de 5 VPCs por projeto (após remover a VPC `default`), os alunos são distribuídos em projetos de grupo (até **4 alunos por projeto**, ex: `einfo-redes-grupo-01` a `10`, suportando até 40 alunos com apenas 10 projetos). Cada projeto possui travas de IAM granulares e limite de cota de CPU, e todos os recursos de cada aluno são isolados pelo sufixo `student_id`.
- **Projeto Central do Facilitador (Hub):** Mantido por Luan Sousa (`terraform/hub-facilitador/`), contendo **2 VPCs de Hub** (`vpc-hub-turma-a` `10.0.1.0/24` para alunos `01–20` e `vpc-hub-turma-b` `10.0.2.0/24` para alunos `21–40`, respeitando o limite de 25 VPC Peerings por VPC do GCP), VMs coletoras leves `e2-micro` (`10.0.1.10` e `10.0.2.10`) que respondem a `ping` e `curl` privado via **VPC Network Peering**, e um serviço no **Cloud Run** (scale-to-zero) que exibe o Mural ao vivo no projetor e **aceita automaticamente os VPC Peerings dos alunos via API**.

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
Nos primeiros laboratórios, **não esconda a complexidade atrás de módulos prontos**. Utilize recursos nativos do provider `hashicorp/google` (`>= 5.0`, Terraform `>= 1.5`) organizados de forma limpa em:
- `versions.tf` / `providers.tf`
- `variables.tf` e `locals.tf`
- `main.tf` (ou separados por contexto: `vpc.tf`, `firewall.tf`, `nat.tf`, `compute.tf`, `peering.tf`)
- `outputs.tf`
- `terraform.tfvars.example`

**Sequência evolutiva dos Labs:**
1. **`01-vpc-subnets/`:** Criação da VPC em modo custom (`auto_create_subnetworks = false`) e sub-rede regional com CIDR dinâmico baseado em `var.student_id`.
2. **`02-firewall-vms/`:** Regras de Firewall (`google_compute_firewall` para SSH/IAP e ICMP), Network Tags e subida de VM de teste sem IP externo (ou com IP externo temporário para demonstrar a diferença).
3. **`03-roteamento-nat/`:** Tabelas de rotas, `google_compute_router` e `google_compute_router_nat` (Cloud NAT) permitindo que VMs privadas acessem a internet com segurança.
4. **`04-vpc-peering-hub/`:** `google_compute_network_peering` conectando a VPC do aluno à VPC Central do facilitador e testando conectividade privada ponta a ponta (`ping` / `curl` interno).

### Fase 2: Boas Práticas com Módulos (`terraform/labs/05-boas-praticas-modules/` + `terraform/modules/`)
Após o aluno dominar os recursos nativos e ver sua rede funcionando:
5. **`05-boas-praticas-modules/` (Demonstração Pré-construída):** Como o tempo final de aula (45 min) é enxuto para refatorar tudo do zero, esta etapa já fica **100% pré-construída** no repositório para o facilitador demonstrar e explicar na tela como organizar o código em **Módulos Reutilizáveis** (`terraform/modules/vpc-network`, `terraform/modules/firewall-rules`, `terraform/modules/vpc-peering`), fornecendo o material pronto para os alunos utilizarem após o curso:
   - Encapsulamento e responsabilidade única de cada módulo.
   - Contratos claros de entrada (`variables.tf` com `type`, `description` e `validation`) e saída (`outputs.tf`).
   - Reaproveitamento para múltiplos ambientes (`dev`, `staging`, `prod`).

---

## 5. Estrutura de Pastas do Repositório

```text
mini-curso-redes-tf-gcp/
├── GEMINI.md                        # Este arquivo de diretrizes e contexto
├── README.md                        # Apresentação principal do repositório
├── docs/                            # Documentação executiva e pedagógica
│   ├── Ficha do Mini Curso.md       # Ficha oficial submetida ao e-info (FACAPE)
│   ├── logo-facape.svg              # Logo oficial da FACAPE (usar nos slides e docs)
│   └── ementa/                      # Cronograma detalhado das 8h (Manhã/Tarde) e roteiro de aula
├── pre-material/                    # Guia e código de preparação prévia (Foundation)
│   └── foundation-check/            # Validação de ferramentas, auth gcloud e projeto inicial
├── terraform/                       # Todo o código de Infraestrutura como Código
│   ├── live-coding/                 # Workspace limpo para construção do zero durante a aula
│   ├── labs/                        # Etapas 01 a 05 (Guia do facilitador e checkpoints dos alunos)
│   ├── modules/                     # Módulos reutilizáveis ensinados na Etapa 05
│   └── hub-facilitador/             # Código da infraestrutura central (Hub) mantida pelo Luan
└── slides/                          # Apresentações visuais do curso
    ├── assets/                      # Imagens, diagramas e logos
    ├── 01-manha-teoria-base/        # Apresentação Web Visual — Turno da Manhã (4h)
    ├── 02-tarde-pratica-avancada/   # Apresentação Web Visual — Turno da Tarde (4h)
    └── exportados/                  # Versões em .pptx e .pdf prontas para download/backup
```

---

## 6. Diretrizes para Criação dos Slides (`slides/`)

- **Formato Principal:** **Apresentação Web Visual Interativa (16:9)** que roda diretamente no navegador em tela cheia (`F11`), com animações didáticas de fluxo de pacotes/redes, *syntax highlighting* para código Terraform/CLI, notas do apresentador e navegação fluida por teclado.
- **Exportação Garantida:** Sempre manter compatibilidade ou gerar os equivalentes em **PDF e PowerPoint (`.pptx`)** dentro de `slides/exportados/`.
- **Identidade Visual:**
  - Utilizar a logo da FACAPE (`docs/logo-facape.svg`), cores institucionais combinadas com a paleta moderna de **Google Cloud** (azul/verde/amarelo/vermelho) e **HashiCorp Terraform** (roxo `#7B42BC` / dark mode técnico para blocos de código).
  - Intercalar slides conceituais visuais (diagramas de sub-rede, firewall, NAT, Peering) com slides de chamada para **"Mão na Massa / Live Coding"**.
