# Pré-material Obrigatório (Foundation) — Redes.tf

<div align="center">
  <img src="../docs/logo-facape.svg" alt="Logo FACAPE" height="95" />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="../slides/assets/logo-einfo.png" alt="Logo e-info 2026" height="78" />

  ### Preparação de Ambiente e Foundation no Google Cloud Platform
  **Minicurso: Redes.tf — da Teoria à Prática com Terraform e GCP (e-info 2026 / FACAPE)**  
  **Facilitador:** Luan Sousa
</div>

---

> [!IMPORTANT]
> **Por que concluir este Pré-material antes do dia do curso?**  
> Nosso minicurso tem **8 horas intensivas e 100% práticas (*Live Coding*)**. Concluir este guia antes da aula garante que suas ferramentas, sua autenticação no Google Cloud e seu acesso ao projeto estejam funcionando perfeitamente, para que você aproveite cada minuto construindo infraestrutura real!

---

## Sumário Rápido

1. [Leitura de Aquecimento (10 min): Conceitos Base de Redes, VPC Peering e Terraform](./conceitos-base.md)
2. [Passo 1 — Consulte seu `student_id` e seu `project_id`](#passo-1--consulte-seu-student_id-e-seu-project_id)
3. [Passo 2 — Escolha seu Ambiente (Google Cloud Shell ou Máquina Local)](#passo-2--escolha-seu-ambiente-google-cloud-shell-ou-máquina-local)
4. [Passo 3 — Autenticação no Google Cloud (`gcloud` e ADC)](#passo-3--autenticação-no-google-cloud-gcloud-e-adc)
5. [Passo 4 — Executando o `foundation-check` com Terraform](#passo-4--executando-o-foundation-check-com-terraform)
6. [Solução de Problemas Comuns (Troubleshooting)](#solução-de-problemas-comuns-troubleshooting)

---

## Passo 1 — Consulte seu `student_id` e seu `project_id`

Você **não precisa de cartão de crédito** nem criar conta de faturamento. O acesso ao projeto do curso no Google Cloud é liberado pelo facilitador diretamente para o **e-mail Google informado na inscrição** (`@gmail.com` ou institucional) — use exatamente essa conta nos passos abaixo.

Na lista oficial da turma enviada pelo facilitador, anote **2 informações essenciais**:

| Parâmetro | O que é? | Exemplo |
| :--- | :--- | :--- |
| **`student_id`** | Seu número único na turma (de `1` a `40`). Ele define seu bloco de IP exclusivo (`10.<ID>.0.0/24`) para evitar conflito de IPs no momento do **VPC Peering** com o Projeto Central! | `7` *(Aluno 07 -> Sub-rede `10.7.0.0/24`)* |
| **`project_id`** | O ID do projeto GCP atribuído à sua bancada/grupo (onde até 4 alunos trabalham de forma isolada usando seus respectivos sufixos `aluno-XX`). Regra: grupo = `ceil(student_id / 4)` (alunos 01–04 → grupo 01, 05–08 → grupo 02, ...). | `einfo-redes-grupo-02` *(Aluno 07)* |

---

## Passo 2 — Escolha seu Ambiente (Google Cloud Shell ou Máquina Local)

Você pode realizar o minicurso usando **qualquer uma das duas opções abaixo**:

### Opção A — Google Cloud Shell (Zero Instalação, direto no navegador)
Ideal se você não quiser instalar nada no seu computador ou se estiver em uma máquina restrita:
1. Acesse [https://shell.cloud.google.com](https://shell.cloud.google.com) logado com a sua conta Google inscrita no curso.
2. O Cloud Shell já traz **Terraform**, **gcloud CLI**, **Git**, **SSH** e um **Editor baseado no VS Code** pré-instalados e atualizados!
3. No terminal do Cloud Shell, verifique as versões:
   ```bash
   terraform -version
   gcloud --version
   git --version
   ```

---

### Opção B — Notebook Pessoal ou Computador do Laboratório da FACAPE
Se preferir rodar tudo localmente no seu computador, instale as ferramentas abaixo:

#### 1. Terraform (`>= 1.5`)
- **Linux (Ubuntu/Debian):**
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
  ```
- **Windows (via Winget no PowerShell):**
  ```powershell
  winget install Hashicorp.Terraform
  ```
- **macOS (via Homebrew):**
  ```bash
  brew tap hashicorp/tap && brew install hashicorp/tap/terraform
  ```

#### 2. Google Cloud CLI (`gcloud`)
- Siga o instalador oficial para seu sistema operacional: [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
- Ou via gerenciador de pacotes:
  - **Windows:** `winget install Google.CloudSDK`
  - **macOS:** `brew install --cask google-cloud-sdk`

#### 3. Git e VS Code
- **Git:** [https://git-scm.com/downloads](https://git-scm.com/downloads)
- **VS Code:** [https://code.visualstudio.com/](https://code.visualstudio.com/)
- **Extensão recomendada no VS Code:** Abra a aba de extensões (`Ctrl+Shift+X`) e instale a extensão oficial **`HashiCorp Terraform`** (para *autocomplete* e destaque de sintaxe HCL).

---

## Passo 3 — Autenticação no Google Cloud (`gcloud` e ADC)

Com o terminal aberto (seja na sua máquina ou no Cloud Shell), clone este repositório e configure suas credenciais:

### 3.1. Clonar o repositório do minicurso
```bash
git clone https://github.com/LuanCSousa/mini-curso-redes-tf-gcp.git
cd mini-curso-redes-tf-gcp
```

### 3.2. Autenticar no `gcloud` (para comandos de terminal e SSH)
```bash
gcloud auth login
```
*(Uma janela do navegador se abrirá para você autenticar com sua conta Google).*

### 3.3. Definir o Projeto GCP atribuído a você
Substitua `SEU_PROJECT_ID` pelo ID do projeto que você recebeu na tabela da turma:
```bash
gcloud config set project SEU_PROJECT_ID
```

### 3.4. Configurar o Application Default Credentials (ADC) para o Terraform
> [!WARNING]
> **Passo Fundamental!** O comando `gcloud auth login` autentica apenas a CLI `gcloud`. Para que o **Terraform** consiga criar recursos no Google Cloud em seu nome, você **precisa** rodar o comando abaixo:

```bash
gcloud auth application-default login
```

---

## Passo 4 — Executando o `foundation-check` com Terraform

Agora vamos validar seu ambiente executando um código Terraform real que verifica suas permissões no GCP, calcula seu plano de endereçamento IP exclusivo (`10.<ID>.0.0/24`) e gera seu **Cartão de Foundation** para o dia do curso!

### 4.1. Acesse a pasta `foundation-check`
```bash
cd pre-material/foundation-check
```

### 4.2. Crie seu arquivo `terraform.tfvars`
Copie o arquivo de exemplo e edite com seus dados:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Abra o arquivo `terraform.tfvars` no VS Code (ou com `nano terraform.tfvars`) e preencha:
```hcl
project_id   = "einfo-redes-grupo-02" # Seu Project ID recebido (Aluno 07 -> grupo 02)
student_id   = 7                      # Seu número único (1 a 40)
student_name = "Seu Nome Completo"    # Seu nome para identificação
```

### 4.3. Inicialize e aplique o Terraform
Execute os 3 comandos clássicos do ciclo de vida do Terraform:

```bash
# 1. Baixa o provider oficial do Google Cloud
terraform init

# 2. Mostra o plano de validação
terraform plan

# 3. Executa a validação e gera o seu Cartão de Foundation
terraform apply
```
*(Quando solicitado `Do you want to perform these actions?`, digite **`yes`** e pressione `Enter`).*

### 4.4. Resultado Esperado
Se tudo estiver correto, você verá no final do terminal um output parecido com este:

```text
Outputs:

cartao_foundation_aluno = <<EOT
====================================================================
  FOUNDATION VALIDADO COM SUCESSO — REDES.TF (e-info / FACAPE)
====================================================================
  Participante      : Seu Nome Completo (aluno-07)
  Projeto GCP Ativo : einfo-redes-grupo-02
  Região Padrão     : us-central1 (Zonas ativas detectadas: 4)
--------------------------------------------------------------------
  SEU PLANO DE REDE PARA O LIVE CODING:
  • Nome da sua VPC : vpc-redes-tf-aluno-07
  • Nome da Subnet  : subnet-us-central1-aluno-07
  • Sua Sub-rede    : 10.7.0.0/24 (Gateway: 10.7.0.1)
  • Hub de Peering  : vpc-hub-turma-a (10.0.1.0/24 -> Alvo: 10.0.1.10)
====================================================================
EOT
```

Pronto! Seu ambiente está **100% preparado** para o dia do minicurso. Não esqueça de ler o resumo rápido em [**`conceitos-base.md`**](./conceitos-base.md) antes da aula!

---

## Solução de Problemas Comuns (Troubleshooting)

<details>
<summary><b>Erro: <code>Attempted to load application default credentials since neither credentials nor access_token was set</code></b></summary>

Você esqueceu de rodar o login de ADC usado pelo Terraform. Execute no terminal:
```bash
gcloud auth application-default login
```
</details>

<details>
<summary><b>Erro: <code>Error 403: Compute Engine API has not been used in project ... or it is disabled</code> ou <code>Permission denied</code></b></summary>

1. Verifique se você digitou o `project_id` correto no arquivo `terraform.tfvars`.
2. Verifique se você autenticou com o mesmo e-mail Gmail que informou na inscrição do curso (`gcloud auth list`).
3. Caso a API ainda não esteja ativa no projeto, execute:
   ```bash
   gcloud services enable compute.googleapis.com --project=SEU_PROJECT_ID
   ```
</details>

<details>
<summary><b>Erro: <code>O student_id deve ser um número inteiro entre 1 e 40</code></b></summary>

No arquivo `terraform.tfvars`, informe apenas o número inteiro do seu ID (por exemplo, `7` em vez de `"07"` ou `0`).
</details>
