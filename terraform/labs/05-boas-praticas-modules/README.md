# Etapa 05 — Boas Práticas de Engenharia Cloud com Terraform Modules (`05-boas-praticas-modules`)

> **Horário no Cronograma:** Turno da Tarde (`16h25 – 17h30` | 65 min: 20 min de conceito + 45 min de demonstração)  
> **Modo de Ensino:** **Demonstração Guiada Pré-construída** (como o tempo final de aula é enxuto para refatorar tudo do zero, esta etapa já está 100% pronta no repositório para o facilitador demonstrar na tela e os alunos levarem como arquitetura de referência para o mercado!).

---

## 1. Por que Modularizar após Aprender os Recursos Nativos?

Nas Etapas 01 a 04 escrevemos cada recurso nativo (`google_compute_network`, `google_compute_subnetwork`, `google_compute_firewall`, `google_compute_route`, `google_compute_router`, `google_compute_router_nat`, `google_compute_network_peering`) de forma explícita para dominar o funcionamento real do Google Cloud Networking.

Em empresas reais que mantêm dezenas de projetos (`dev`, `staging`, `prod`), copiar e colar esses mesmos arquivos em cada ambiente gera **código duplicado** e **risco de configuração inconsistente**. A solução padrão de engenharia é encapsular a infraestrutura em **Módulos Reutilizáveis** ([`../../modules/`](../../modules/README.md)):

| Módulo | Responsabilidade Única | Principais Entradas (`variables.tf`) | Principais Saídas (`outputs.tf`) |
| :--- | :--- | :--- | :--- |
| [`modules/vpc-network`](../../modules/vpc-network/README.md) | Cria VPC Custom, Sub-rede Regional e Cloud Router/NAT condicional (`count`) | `vpc_name` (validado com `regex`), `subnet_cidr` (validado com `can(cidrhost(...))`), `enable_cloud_nat`, `*_description` | `vpc_id`, `vpc_self_link`, `subnet_id`, `subnet_cidr`, `nat_name` |
| [`modules/firewall-rules`](../../modules/firewall-rules/README.md) | Aplica governança de perímetro (SSH via Cloud IAP + ICMP interno) | `vpc_id`, `name_suffix`, `internal_source_ranges` (lista de CIDRs validada), `iap_target_tags` | `ssh_iap_rule_name`, `iap_target_tags` |
| [`modules/vpc-peering`](../../modules/vpc-peering/README.md) | Conecta uma VPC Spoke a uma VPC Hub remota | `peering_name`, `local_vpc_self_link`, `peer_project_id`, `peer_vpc_name` (todos validados) | `peering_name`, `peering_state` |

Arquivos desta etapa:
- [`main.tf`](./main.tf): os 3 blocos `module`.
- [`compute.tf`](./compute.tf) e [`routes.tf`](./routes.tf): a VM e a rota explícita, que continuam na raiz.
- [`moved.tf`](./moved.tf): refatoração sem recriar nada (seção 3).
- [`envs/`](./envs/): exemplos de parâmetros por ambiente (`dev`, `staging`, `prod`).

---

## 2. Roteiro de Demonstração para o Facilitador

1. Abrir [`main.tf`](./main.tf) no projetor e mostrar como toda a rede das Etapas 01 a 04 foi resumida em 3 blocos `module` (`module "vpc"`, `module "firewall"` e `module "peering_hub"`).
2. Abrir [`../../modules/vpc-network/variables.tf`](../../modules/vpc-network/variables.tf) e destacar os contratos com `validation`:
   ```hcl
   validation {
     condition     = can(cidrhost(var.subnet_cidr, 0))
     error_message = "O valor de subnet_cidr deve ser um endereço IPv4 em notação CIDR válida (ex: 10.7.0.0/24)."
   }
   ```
3. Mostrar como os módulos conversam entre si: o `module "firewall"` recebe `vpc_id = module.vpc.vpc_id` e o `module "peering_hub"` recebe `local_vpc_self_link = module.vpc.vpc_self_link`.
4. Explicar que, sempre que adicionamos ou alteramos um bloco `module`, devemos rodar `terraform init` para que o Terraform registre os módulos filhos em `.terraform/modules/`.
5. **O grande final: migrar a rede viva para módulos sem derrubar nada** (seção 3).

---

## 3. Refatoração sem Downtime com `moved {}` (Demonstração ao Vivo)

Ao mover um recurso para dentro de um módulo, o **endereço** dele no state muda (ex: `google_compute_network.vpc_aluno` → `module.vpc.google_compute_network.vpc`). Sem aviso, o Terraform planejaria **destruir e recriar** a VPC, a VM e o Peering. O arquivo [`moved.tf`](./moved.tf) informa que é o **mesmo objeto real** com um novo endereço.

Os nomes e descrições usados aqui são **idênticos** aos do live-coding (Etapa 04). Por isso o plano fica limpo:

```bash
cd terraform/labs/05-boas-praticas-modules
cp ../../live-coding/terraform.tfvars .       # mesmo project_id / student_id
cp ../../live-coding/terraform.tfstate .      # o state da rede construída durante a aula

terraform init
terraform plan
# Resultado esperado:
#   # google_compute_network.vpc_aluno has moved to module.vpc.google_compute_network.vpc
#   ...
#   Plan: 0 to add, 0 to change, 0 to destroy.
```

> ⚠️ **Não mantenha dois states gerenciando a mesma rede.** Depois de copiar o state para cá, opere **só por esta pasta** (inclusive o `terraform destroy` do fim da aula). Se preferir só demonstrar, rode apenas o `plan` e apague o `terraform.tfstate` copiado; o live-coding continua como dono da rede.
>
> ⚠️ **Sem state copiado**, um `terraform apply` aqui tentaria criar recursos com os mesmos nomes da sua rede do live-coding e falharia com `already exists`. Use um `student_id` livre ou faça o `destroy` do live-coding antes.

---

## 4. Reaproveitamento para Múltiplos Ambientes (`dev` / `staging` / `prod`)

O mesmo código atende a vários ambientes; muda apenas o arquivo de variáveis e o state. Em empresas, cada ambiente tem seu **próprio projeto GCP** e seu **próprio state** (backend remoto ou workspace):

```bash
cp envs/dev.tfvars.example envs/dev.tfvars    # .tfvars não são versionados
terraform workspace new dev
terraform plan -var-file=envs/dev.tfvars
```

---

## 5. Uso pelos Alunos Após o Curso

Copie esta pasta e `terraform/modules/` para o seu próprio repositório, ajuste o `source` dos módulos (ou publique-os em um repositório Git versionado com tags como `?ref=v1.0.0`) e reutilize o padrão nos seus projetos.
