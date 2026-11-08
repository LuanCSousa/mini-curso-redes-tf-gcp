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

  # Opcionais (úteis para migrar recursos existentes sem diff — ver labs/05 moved.tf):
  # vpc_description    = "..."   # alterar a descrição de uma VPC existente força recriação!
  # subnet_description = "..."
  # router_name        = "router-us-central1-aluno-07"
  # nat_name           = "nat-us-central1-aluno-07"
}
```

Todas as entradas críticas têm `validation` (nomes no padrão RFC 1035 do GCP e CIDR válido).
