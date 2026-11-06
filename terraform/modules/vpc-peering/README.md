# Módulo Terraform: `vpc-peering`

Módulo reutilizável para estabelecimento padronizado de **VPC Network Peering** entre Spokes e Hub no Google Cloud.

## Exemplo de Uso

```hcl
module "peering_hub" {
  source = "../../modules/vpc-peering"

  peering_name        = "peer-${local.student_suffix}-to-hub"
  local_vpc_self_link = module.vpc.vpc_self_link
  peer_project_id     = var.hub_project_id
  peer_vpc_name       = local.hub_vpc_name
}
```
