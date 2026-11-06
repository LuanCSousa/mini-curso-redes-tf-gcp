# Módulo Terraform: `vpc-network`

Módulo reutilizável que encapsula a criação padronizada de:
- **VPC Customizada Global** (`auto_create_subnetworks = false`)
- **Sub-rede Regional** com validação automática de CIDR (`can(cidrhost(...))`) e `private_ip_google_access = true`
- **Cloud Router + Cloud NAT** opcionais (`enable_cloud_nat = true`)

## Exemplo de Uso

```hcl
module "vpc" {
  source = "../../modules/vpc-network"

  project_id       = var.project_id
  vpc_name         = local.vpc_name
  region           = var.region
  subnet_name      = local.subnet_name
  subnet_cidr      = local.subnet_cidr
  enable_cloud_nat = true
}
```
