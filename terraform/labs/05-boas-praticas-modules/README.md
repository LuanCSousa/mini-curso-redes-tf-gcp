# Etapa 05 — Boas Práticas de Engenharia Cloud com Terraform Modules (`05-boas-praticas-modules`)

> **Horário no Cronograma:** Turno da Tarde (`16h40 – 17h35` | 55 min)  
> **Modo de Ensino:** **Demonstração Guiada Pré-construída** (como o tempo final de aula é enxuto para refatorar tudo do zero, esta etapa já está 100% pronta no repositório para o facilitador demonstrar na tela e os alunos levarem como arquitetura de referência para o mercado!).

---

## 1. Por que Modularizar após Aprender os Recursos Nativos?

Nas Etapas 01 a 04 escrevemos cada recurso nativo (`google_compute_network`, `google_compute_subnetwork`, `google_compute_firewall`, `google_compute_router`, `google_compute_router_nat`, `google_compute_network_peering`) de forma explícita para dominar o funcionamento real do Google Cloud Networking.

Em empresas reais que mantêm dezenas de projetos (`dev`, `staging`, `prod`), copiar e colar esses mesmos 7 arquivos em cada ambiente gera **código duplicado** e **risco de configuração inconsistente**. A solução padrão de engenharia é encapsular a infraestrutura em **Módulos Reutilizáveis** ([`../../modules/`](../../modules/README.md)):

| Módulo | Responsabilidade Única | Principais Entradas (`variables.tf`) | Principais Saídas (`outputs.tf`) |
| :--- | :--- | :--- | :--- |
| [`modules/vpc-network`](../../modules/vpc-network/README.md) | Cria VPC Custom, Sub-rede Regional e Cloud Router/NAT condicional (`count`) | `vpc_name`, `subnet_cidr` (validado com `can(cidrhost(...))`), `enable_cloud_nat` | `vpc_id`, `vpc_self_link`, `subnet_id`, `subnet_cidr`, `nat_name` |
| [`modules/firewall-rules`](../../modules/firewall-rules/README.md) | Aplica governança de perímetro (SSH via Cloud IAP + ICMP/HTTP interno) | `vpc_id`, `name_suffix`, `internal_source_ranges`, `iap_target_tags` | `ssh_iap_rule_name`, `iap_target_tags` |
| [`modules/vpc-peering`](../../modules/vpc-peering/README.md) | Conecta uma VPC Spoke a uma VPC Hub remota | `peering_name`, `local_vpc_self_link`, `peer_project_id`, `peer_vpc_name` | `peering_name`, `peering_state` |

---

## 2. Roteiro de Demonstração para o Facilitador

1. Abrir [`main.tf`](./main.tf) no projetor e mostrar como toda a rede das Etapas 01 a 04 foi resumida em apenas 3 blocos `module` (`module "vpc"`, `module "firewall"` e `module "peering_hub"`).
2. Abrir [`../../modules/vpc-network/variables.tf`](../../modules/vpc-network/variables.tf) e destacar a validação:
   ```hcl
   validation {
     condition     = can(cidrhost(var.subnet_cidr, 0))
     error_message = "O valor de subnet_cidr deve ser um endereço IPv4 em notação CIDR válida."
   }
   ```
3. Mostrar como os módulos conversam entre si: o `module "firewall"` recebe `vpc_id = module.vpc.vpc_id` e o `module "peering_hub"` recebe `local_vpc_self_link = module.vpc.vpc_self_link`.
4. Explicar que sempre que adicionamos ou alteramos um bloco `module`, devemos rodar `terraform init` para que o Terraform registre os módulos filhos em `.terraform/modules/`.
