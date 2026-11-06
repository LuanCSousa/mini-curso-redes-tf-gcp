# Módulo Terraform: `firewall-rules`

Módulo reutilizável para governança de perímetro e microsegmentação no Google Cloud:
- **Zero-Trust SSH via Cloud IAP** (`35.235.240.0/20` -> `tcp:22` restrito por `target_tags`)
- **Tráfego Interno Controlado** (`icmp` e `tcp:80,8080` entre sub-redes autorizadas)

## Exemplo de Uso

```hcl
module "firewall" {
  source = "../../modules/firewall-rules"

  project_id             = var.project_id
  vpc_id                 = module.vpc.vpc_id
  name_suffix            = local.student_suffix
  internal_source_ranges = [module.vpc.subnet_cidr, "10.0.1.0/24", "10.0.2.0/24"]
}
```
