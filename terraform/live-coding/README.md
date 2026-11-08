# Workspace de Live Coding (Construção do Zero ao Fim)

Este é o **diretório de trabalho principal** durante as 8 horas do minicurso **"Redes.tf: da Teoria à Prática com Terraform e GCP"**!

Aqui, o facilitador (**Luan Sousa**) e os participantes **construirão os arquivos Terraform do início ao fim**, passo a passo, evoluindo desde a criação da primeira VPC até a conexão via **VPC Peering** com o Projeto Central e a organização em **Módulos**.

---

## Como Iniciar seu Workspace na Aula

```bash
# Entre nesta pasta
cd terraform/live-coding

# Ao longo da aula criaremos juntos:
# 1. versions.tf, providers.tf, variables.tf e terraform.tfvars (Etapa 00)
# 2. locals.tf, vpc.tf e outputs.tf                             (Etapa 01)
# 3. firewall.tf e compute.tf                                   (Etapa 02)
# 4. routes.tf e nat.tf                                         (Etapa 03)
# 5. peering.tf                                                 (Etapa 04)
```

> [!IMPORTANT]
> Use **exatamente** esses nomes de arquivo. Se você criar, por exemplo, `rede.tf` no lugar de `vpc.tf` e depois copiar um checkpoint, o mesmo recurso ficará declarado em dois arquivos e o Terraform acusará `Duplicate resource`. Para resolver, apague o arquivo com nome diferente.

---

## Ciclo de Cada Etapa

Você roda o Terraform **na sua própria máquina ou no seu Cloud Shell**, sempre dentro desta pasta. O `terraform.tfstate` gerado aqui é **só seu**: os colegas do mesmo projeto de grupo têm o state deles, e o sufixo `aluno-XX` + o CIDR `10.<ID>.0.0/24` garantem que os recursos não colidam.

**Uma única vez (Etapa 00):** depois de criar `versions.tf`, `providers.tf`, `variables.tf` e `terraform.tfvars`:

```bash
terraform init
```

**A cada etapa (01 a 04):**

```bash
terraform fmt && terraform validate
terraform plan     # o state é cumulativo: o plano mostra só o que a etapa acrescenta
terraform apply    # confirme com "yes"
```

**No final da aula:**

```bash
terraform destroy
```

> [!WARNING]
> **Não apague esta pasta nem troque de máquina no meio da aula.** Sem o `terraform.tfstate`, o Terraform perde o controle do que criou e os recursos ficam órfãos no projeto.
>
> **Cloud Shell:** normalmente já tem credenciais. Se você trocar de conta Google, rode de novo `gcloud auth application-default login`.

---

## Comandos Rápidos de Checkpoint (Caso perca algum passo)

Se o seu código apresentar algum erro de digitação ou se você quiser avançar diretamente para o ponto exato da turma em qualquer momento da aula, basta copiar os arquivos `.tf` do laboratório correspondente em [`../labs/`](../labs/README.md) (seu arquivo `terraform.tfvars` será preservado):

```bash
# Sincronizar com o final da Etapa 01 (VPC + Sub-rede)
cp ../labs/01-vpc-subnets/*.tf .

# Sincronizar com o final da Etapa 02 (Firewall + Cloud IAP + VM Privada)
cp ../labs/02-firewall-vms/*.tf .

# Sincronizar com o final da Etapa 03 (Cloud Router + Cloud NAT)
cp ../labs/03-roteamento-nat/*.tf .

# Sincronizar com o final da Etapa 04 (VPC Network Peering com o Hub Central)
cp ../labs/04-vpc-peering-hub/*.tf .
```

Depois de copiar, rode `terraform plan && terraform apply` normalmente.

> [!IMPORTANT]
> **Etapa 04 traz variáveis novas.** O `cp` não altera o seu `terraform.tfvars`, então adicione à mão (mesmo que tenha copiado o checkpoint):
>
> ```hcl
> student_name   = "Seu Nome Completo"
> hub_project_id = "einfo-redes-hub-central"
> ```
>
> Sem elas, o `terraform plan` vai pedir os valores no prompt ou falhar na validação.

> **Por que dá para copiar por cima?** Todos os labs usam os **mesmos endereços de recurso** (`google_compute_network.vpc_aluno`, `google_compute_instance.vm_aluno`...). Assim, o `terraform.tfstate` desta pasta continua válido e o `plan` mostra só o que falta criar.
>
> A Etapa 05 (módulos) é demonstrada em [`../labs/05-boas-praticas-modules/`](../labs/05-boas-praticas-modules/README.md), inclusive como migrar o state desta pasta para módulos com blocos `moved` **sem recriar nada**.
