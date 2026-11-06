# Módulos do Terraform — Boas Práticas de Engenharia Cloud

Esta pasta armazena os módulos reutilizáveis construídos e explicados na **Etapa 05 (`labs/05-boas-praticas-modules`)**.

## Por que usar Módulos?
Após construirmos todos os recursos de forma explícita nas etapas 01 a 04 para entender cada propriedade do Google Cloud Networking, aplicamos as boas práticas de mercado organizando o código em módulos com responsabilidades bem definidas:

- **`vpc-network/`:** Criação padronizada de VPC customizada, sub-redes, Cloud Router e Cloud NAT.
- **`firewall-rules/`:** Gerenciamento declarativo de regras de Firewall (Ingress/Egress, IAP, Tags).
- **`vpc-peering/`:** Fechamento de VPC Network Peering entre Spokes e Hub.

Cada módulo segue o padrão oficial da HashiCorp:
- `versions.tf` (requisitos de versão de Terraform e providers)
- `variables.tf` (contratos de entrada tipados, documentados e com `validation`)
- `main.tf` (recursos encapsulados)
- `outputs.tf` (valores expostos para composição entre módulos)
- `README.md` (documentação de inputs e outputs)
