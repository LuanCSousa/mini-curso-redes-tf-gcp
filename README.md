<div align="center">
  <img src="docs/logo-facape.svg" alt="Logo FACAPE" height="110" />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="slides/assets/logo-einfo.png" alt="Logo e-info 2026" height="90" />

  # Redes.tf: da Teoria à Prática com Terraform e GCP

  **Minicurso Oficial — e-info 2026 | FACAPE**

  ![Carga Horária](https://img.shields.io/badge/Carga_Hor%C3%A1ria-8_Horas-0A66C2?style=for-the-badge)
  ![Terraform](https://img.shields.io/badge/Terraform-%3E%3D_1.5-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
  ![Google Cloud](https://img.shields.io/badge/Google_Cloud-VPC_Networking-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
  ![Modalidade](https://img.shields.io/badge/Modalidade-100%25_Pr%C3%A1tico_(Live_Coding)-2EA44F?style=for-the-badge)
</div>

---

## Sobre o Minicurso

Um mergulho prático de **8 horas** nos fundamentos de **Infraestrutura de Redes**, saindo da teoria de sala de aula direto para a nuvem. Utilizando o **Google Cloud Platform (GCP)** e as boas práticas do **Terraform**, o curso conecta conceitos clássicos de redes de computadores (**sub-redes, CIDR, roteamento, firewalls, NAT e VPC Peering**) com sua aplicação real em ambientes cloud modernos.

Durante o curso, **construiremos toda a infraestrutura do zero ao fim (*Live Coding*)**, começando com recursos nativos para entender profundamente como cada componente funciona e evoluindo até a organização profissional em **Módulos do Terraform (`modules/`)**.

---

## Facilitador

<table>
  <tr>
    <td width="160" align="center">
      <img src="docs/Foto%20Perfil.jpeg" alt="Luan Sousa" width="140" style="border-radius: 50%;" />
    </td>
    <td>
      <strong>Luan Sousa</strong><br/>
      <em>Cloud Engineer na <strong>SantoDigital</strong> (Parceira Google Cloud)</em><br/><br/>
      Atua no desenho, na implantação e na sustentação de infraestrutura em nuvem. Sua trajetória inclui projetos de Fullstack, DevOps, Infraestrutura e SecOps, trazendo ao curso uma visão completa de como redes são projetadas, automatizadas e protegidas em ambientes reais. É certificado <strong>Google Cloud Digital Leader</strong> e bacharelando em <strong>Ciência da Computação pela FACAPE</strong>.
    </td>
  </tr>
</table>

---

## Arquitetura do Laboratório (Dinâmica *Hub-and-Spoke*)

Os participantes são distribuídos em **projetos GCP de grupo** (até **4 alunos por projeto**, `einfo-redes-grupo-01` a `10`), e cada um constrói **a sua própria VPC do zero**, isolada pelo sufixo `aluno-XX`. Na etapa de interconexão, todas as redes dos alunos se conectam via **VPC Network Peering** a um **Projeto Central (Hub)** mantido pelo facilitador. Como o GCP permite no máximo **25 peerings por VPC**, o Hub é dividido em **2 VPCs** ("Turma A" e "Turma B" são apenas *shards* do Hub, e a aula é uma só):

```mermaid
flowchart TB
    subgraph Hub["Projeto Central do Facilitador (einfo-redes-hub-central)"]
        HUB_A["vpc-hub-turma-a<br/>10.0.1.0/24<br/>VM coletora 10.0.1.10"]
        HUB_B["vpc-hub-turma-b<br/>10.0.2.0/24<br/>VM coletora 10.0.2.10"]
        MURAL["Cloud Run<br/>Mural ao Vivo (projetor)"]
        HUB_A -. "check-ins (via Cloud NAT)" .-> MURAL
        HUB_B -. "check-ins (via Cloud NAT)" .-> MURAL
    end

    subgraph G1["Projeto einfo-redes-grupo-01 (alunos 01–04)"]
        S1["vpc-redes-tf-aluno-01<br/>10.1.0.0/24"]
        S4["vpc-redes-tf-aluno-04<br/>10.4.0.0/24"]
    end

    subgraph G6["Projeto einfo-redes-grupo-06 (alunos 21–24)"]
        S21["vpc-redes-tf-aluno-21<br/>10.21.0.0/24"]
    end

    subgraph G10["Projeto einfo-redes-grupo-10 (alunos 37–40)"]
        S40["vpc-redes-tf-aluno-40<br/>10.40.0.0/24"]
    end

    S1 <== "VPC Peering" ==> HUB_A
    S4 <== "VPC Peering" ==> HUB_A
    S21 <== "VPC Peering" ==> HUB_B
    S40 <== "VPC Peering" ==> HUB_B
```

Cada VPC de aluno contém: sub-rede regional, regras de firewall (SSH via IAP + ICMP), VM privada `e2-micro` sem IP público, rota estática explícita, Cloud Router + Cloud NAT e o peering com o Hub.

> [!IMPORTANT]
> **Convenção de Endereçamento por Aluno (`student_id`):**  
> Cada participante recebe um **ID numérico de `1` a `40`** e usa o bloco **`10.<ID>.0.0/24`** na sua sub-rede (ex: Aluno `07` → `10.7.0.0/24`). Assim, nenhuma rede de aluno se sobrepõe às do Hub (`10.0.1.0/24` e `10.0.2.0/24`) nem às dos colegas (*CIDR overlap*). Alunos `01–20` fazem peering com `vpc-hub-turma-a`, e alunos `21–40` com `vpc-hub-turma-b`.

---

## Estrutura do Repositório

O repositório está organizado em pastas de contexto para facilitar tanto o acompanhamento ao vivo quanto a consulta posterior:

```text
mini-curso-redes-tf-gcp/
├── docs/                            # Ficha executiva do minicurso, logos, foto do facilitador e ementa
│   ├── Ficha do Mini Curso.md       # Ficha oficial do curso no evento e-info
│   ├── Foto Perfil.jpeg             # Foto oficial do facilitador (Luan Sousa)
│   ├── LOGO E-INFO.png              # Logo oficial do evento e-info 2026
│   ├── logo-facape.svg              # Identidade visual da FACAPE
│   └── ementa/                      # Cronograma detalhado das 8h (Manhã e Tarde) e roteiro
├── pre-material/                    # OBRIGATÓRIO ANTES DO CURSO: Setup de ferramentas e foundation GCP
│   └── foundation-check/            # Script/Terraform inicial para testar seu ambiente antes da aula
├── terraform/                       # Infraestrutura como Código (Terraform + GCP)
│   ├── live-coding/                 # Diretório limpo onde construímos tudo do zero ao fim na aula
│   ├── labs/                        # Guia passo a passo e gabarito (checkpoints) de cada etapa:
│   │   ├── 01-vpc-subnets/          # Etapa 01: VPC Customizada e Sub-redes
│   │   ├── 02-firewall-vms/         # Etapa 02: Regras de Firewall, Tags e VMs de teste
│   │   ├── 03-roteamento-nat/       # Etapa 03: Rota explícita, Cloud Router e Cloud NAT
│   │   ├── 04-vpc-peering-hub/      # Etapa 04: VPC Peering com o Projeto Central (Hub)
│   │   └── 05-boas-praticas-modules/# Etapa 05: Módulos do Terraform + migração com moved {}
│   ├── modules/                     # Módulos reutilizáveis de referência (Boas Práticas)
│   └── hub-facilitador/             # Infraestrutura do Projeto Central mantida pelo facilitador
└── slides/                          # Apresentações visuais do minicurso
    ├── 01-manha-teoria-base/        # Slides Interativos — Turno da Manhã (4h)
    ├── 02-tarde-pratica-avancada/   # Slides Interativos — Turno da Tarde (4h)
    └── exportados/                  # Arquivos .pptx e .pdf para download e leitura offline
```

---

## Pré-requisitos e Preparação (*Pré-material*)

> [!WARNING]
> **Atenção Participante:** A conclusão do [**Pré-material (`pre-material/`)**](./pre-material/README.md) antes do dia do minicurso é **indispensável** para preparar o *foundation* do seu projeto GCP e garantir que você acompanhe a prática desde o primeiro minuto.

### Ferramentas Necessárias (Laboratório ou Notebook Pessoal)
- **Terraform** (`>= 1.5`)
- **Google Cloud CLI (`gcloud`)**
- **Git**
- **VS Code** com a extensão *HashiCorp Terraform*
- **Cliente SSH** (nativo no Linux, macOS e Windows 10+)
- **Conta Google (Gmail)** ativa, informada na inscrição (não é necessário cartão de crédito; os projetos GCP do curso são fornecidos pelo facilitador, que libera o acesso para o seu e-mail).

> [!TIP]
> **Alternativa Zero Instalação:** Caso prefira não instalar nada na sua máquina pessoal, você poderá realizar todo o minicurso utilizando o **Google Cloud Shell** diretamente pelo navegador, que já traz `terraform`, `gcloud`, `git` e editor VS Code integrados!

---

## Jornada das 8 Horas (Resumo)

| Turno | Duração | Foco Principal | Etapas Práticas |
| :--- | :---: | :--- | :--- |
| **Pré-curso** | *Assíncrono* | Setup de ferramentas, autenticação GCP e validação do acesso ao projeto do seu grupo (*Foundation*) | [`pre-material/`](./pre-material/README.md) |
| **Manhã** | **4h** | Fundamentos de Redes na Nuvem, Arquitetura de VPC no GCP, Introdução ao Terraform, Sub-redes, Endereçamento CIDR e Firewalls | [`01-vpc-subnets`](./terraform/labs/README.md) e [`02-firewall-vms`](./terraform/labs/README.md) |
| **Tarde** | **4h** | Tabela de Rotas, Saída Segura com Cloud NAT, Interconexão com o Projeto Central via VPC Peering e Boas Práticas de Modularização (`modules/`) | [`03-roteamento-nat`](./terraform/labs/README.md), [`04-vpc-peering-hub`](./terraform/labs/README.md) e [`05-boas-praticas-modules`](./terraform/labs/README.md) |
