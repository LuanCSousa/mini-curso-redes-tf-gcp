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
# 4. nat.tf                                                     (Etapa 03)
# 5. peering.tf                                                 (Etapa 04)
```

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
