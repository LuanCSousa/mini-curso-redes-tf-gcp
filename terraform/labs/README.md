# Laboratórios Guiados e Checkpoints — Terraform + GCP

Esta pasta contém todas as etapas práticas do minicurso já estruturadas. Ela cumpre dois papéis fundamentais:
1. **Guia de Condução para o Facilitador:** Sequência didática de como construir e explicar cada recurso ao vivo do zero ao fim.
2. **Checkpoint / Gabarito para os Alunos:** Caso alguém se atrase durante o *Live Coding* em `../live-coding/`, basta consultar ou copiar o ponto exato da etapa correspondente.

## Sequência das Etapas

| Pasta | Tema de Redes | Recursos Terraform Principais |
| :--- | :--- | :--- |
| [`01-vpc-subnets/`](./01-vpc-subnets/README.md) | VPC Global, Sub-redes Regionais e CIDR (`10.<ID>.0.0/24`) | `google_compute_network`, `google_compute_subnetwork` |
| [`02-firewall-vms/`](./02-firewall-vms/README.md) | Firewall Stateful, Ingress/Egress, Network Tags, IAP e VMs | `google_compute_firewall`, `google_compute_instance` |
| [`03-roteamento-nat/`](./03-roteamento-nat/README.md) | Tabelas de Roteamento, Cloud Router e SNAT com Cloud NAT | `google_compute_route`, `google_compute_router`, `google_compute_router_nat` |
| [`04-vpc-peering-hub/`](./04-vpc-peering-hub/README.md) | Interconexão Privada (VPC Peering) com o Projeto Central | `google_compute_network_peering` |
| [`05-boas-praticas-modules/`](./05-boas-praticas-modules/README.md) | Boas Práticas de Engenharia Cloud: Modularização | Blocos `module` consumindo [`../modules/`](../modules/README.md) |
