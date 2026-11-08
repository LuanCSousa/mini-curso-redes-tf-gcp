# Módulo Terraform: `firewall-rules`

Módulo reutilizável para governança de perímetro e microsegmentação no Google Cloud:
- **Zero-Trust SSH via Cloud IAP** (`35.235.240.0/20` -> `tcp:22` restrito por `target_tags`)
- **ICMP Interno Controlado** (`icmp` apenas a partir das faixas em `internal_source_ranges`)

> O firewall do GCP é *stateful*: respostas de conexões iniciadas pela VM (ex: `curl` para o Hub) voltam sem regra de ingress. Por isso não abrimos portas TCP aqui.

## Exemplo de Uso

```hcl
module "firewall" {
  source = "../../modules/firewall-rules"

  project_id             = var.project_id
  vpc_id                 = module.vpc.vpc_id
  name_suffix            = local.student_suffix
  internal_source_ranges = [module.vpc.subnet_cidr]
}
```
