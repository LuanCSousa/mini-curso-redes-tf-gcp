# Foundation Check — Validação Prática do Pré-material

Este diretório contém o seu **primeiro código Terraform** do minicurso **Redes.tf: da Teoria à Prática com Terraform e GCP**.

Ele tem **custo zero (`US$ 0.00`)** e serve para:
1. Testar se o binário do **Terraform (`>= 1.5`)** está funcionando.
2. Validar se suas credenciais **ADC (`gcloud auth application-default login`)** estão autenticando corretamente no projeto GCP do seu grupo.
3. Confirmar que a API do **Compute Engine (`compute.googleapis.com`)** está acessível para a sua conta.
4. Gerar o seu **Cartão de Foundation** com o nome exato da sua VPC, o seu bloco CIDR (`10.<ID>.0.0/24`) e o endereço do Hub Central que você usará durante a aula.

---

## Como Executar

```bash
# 1. Crie seu arquivo de variáveis a partir do modelo
cp terraform.tfvars.example terraform.tfvars

# 2. Edite o arquivo terraform.tfvars com seu project_id, student_id e student_name
code terraform.tfvars   # ou: nano terraform.tfvars

# 3. Inicialize o Terraform
terraform init

# 4. Visualize o plano de execução
terraform plan

# 5. Aplique e gere seu Cartão de Foundation
terraform apply
```

Caso precise de instruções mais detalhadas sobre instalação das ferramentas ou login no `gcloud`, consulte o [**Guia Principal do Pré-material (`../README.md`)**](../README.md).
