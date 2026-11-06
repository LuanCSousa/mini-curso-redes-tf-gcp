# Etapa 01 — VPC Customizada Global, Sub-rede Regional e CIDR (`01-vpc-subnets`)

> **Horário no Cronograma:** Turno da Manhã (`10h20 – 11h00` | 40 min)  
> **Modo de Ensino:** *Live Coding* do zero em `terraform/live-coding/` (este diretório serve como **Roteiro do Facilitador** e **Checkpoint/Gabarito** para os alunos).

---

## 1. Objetivos de Redes e Cloud desta Etapa

1. **VPC Global vs. Sub-rede Regional:** Compreender na prática que no Google Cloud a `google_compute_network` (VPC) é um recurso **Global** operado pela SDN Andromeda e não possui faixa de IP própria; quem recebe o bloco CIDR é a `google_compute_subnetwork` (**Regional**, ex: `us-central1`).
2. **Modo Customizado (`auto_create_subnetworks = false`):** Entender por que o modo automático (`10.128.0.0/9`) é uma armadilha para ambientes reais que precisam de **VPC Peering** ou **Cloud VPN**.
3. **Endereçamento CIDR sem Conflito (`10.<student_id>.0.0/24`):** Utilizar interpolação e funções nativas do Terraform (`format("aluno-%02d", var.student_id)`) para que até 40 alunos tenham redes isoladas e prontas para interconexão.
4. **Os 4 IPs Reservados do GCP:** Comprovar no output do Terraform que o endereço `.1` (`gateway_address = 10.<ID>.0.1`) já nasce alocado como Default Gateway Virtual da sub-rede.

---

## 2. Sequência de Construção no *Live Coding* (`terraform/live-coding/`)

Durante a aula, construímos os arquivos na seguinte ordem lógica:

### Passo 1: Base do Projeto (`versions.tf`, `providers.tf`, `variables.tf` e `terraform.tfvars`)
*(Já iniciados na Etapa 00 antes do intervalo da manhã)*:
- [`versions.tf`](./versions.tf) — Trava `required_version = ">= 1.5.0"` e `hashicorp/google ~> 5.0`.
- [`providers.tf`](./providers.tf) — Configura `project`, `region` e `zone`.
- [`variables.tf`](./variables.tf) — Declara `project_id`, `student_id` (com bloco `validation` de `1` a `40`), `region` e `zone`.

### Passo 2: Inteligência de Nomenclatura e CIDR (`locals.tf`)
Criamos o arquivo [`locals.tf`](./locals.tf):
- `student_suffix = format("aluno-%02d", var.student_id)`
- `vpc_name = "vpc-redes-tf-${local.student_suffix}"`
- `subnet_name = "subnet-${var.region}-${local.student_suffix}"`
- `subnet_cidr = "10.${var.student_id}.0.0/24"`

### Passo 3: Declaração da VPC e Sub-rede (`vpc.tf`)
Criamos o arquivo [`vpc.tf`](./vpc.tf):
- Recurso `google_compute_network.vpc_aluno` com `auto_create_subnetworks = false` e `routing_mode = "REGIONAL"`.
- Recurso `google_compute_subnetwork.subnet_principal` referenciando `network = google_compute_network.vpc_aluno.id` (demonstrando o **Grafo de Dependência Implícita** do Terraform) e `private_ip_google_access = true`.

### Passo 4: Exposição dos Resultados (`outputs.tf`)
Criamos o arquivo [`outputs.tf`](./outputs.tf) expondo `vpc_name`, `subnet_cidr` e `subnet_gateway_ip`.

---

## 3. Comandos de Execução e Validação

No terminal, dentro de `terraform/live-coding/`:

```bash
# 1. Formatar e validar a sintaxe HCL
terraform fmt
terraform validate

# 2. Inspecionar o plano de execução (2 recursos a criar: VPC + Subnet)
terraform plan

# 3. Provisionar a rede no Google Cloud
terraform apply
```

### Saída Esperada (`Outputs`):
```text
Outputs:

subnet_cidr       = "10.7.0.0/24"
subnet_gateway_ip = "10.7.0.1"
subnet_name       = "subnet-us-central1-aluno-07"
vpc_id            = "projects/einfo-redes-grupo-02/global/networks/vpc-redes-tf-aluno-07"
vpc_name          = "vpc-redes-tf-aluno-07"
```

### Validação via `gcloud` CLI ou Console Web:
```bash
# Listar sua VPC recém-criada
gcloud compute networks list --filter="name~aluno"

# Inspecionar as rotas geradas automaticamente pelo GCP (Rota Local + Default Internet Gateway)
gcloud compute routes list --filter="network~vpc-redes-tf-aluno"
```

---

## 4. Checkpoint de Recuperação Rápida (Se você se atrasou)

Se precisar sincronizar sua pasta `terraform/live-coding/` com o gabarito completo desta Etapa 01:

```bash
cp ../labs/01-vpc-subnets/*.tf ../live-coding/
```
