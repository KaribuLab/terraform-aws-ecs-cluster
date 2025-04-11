# Módulo Terraform AWS ECS Cluster

Este módulo Terraform crea un clúster de Amazon ECS (Elastic Container Service) en AWS.

## Uso

```hcl
module "ecs_cluster" {
  source = "github.com/KaribuLab/terraform-aws-ecs-cluster"

  cluster_name = "mi-cluster-ecs"
  tags = {
    Environment = "production"
    Project     = "mi-proyecto"
  }
}
```

## Requisitos

| Nombre | Versión |
|--------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0 |

## Providers

| Nombre | Versión |
|--------|---------|
| aws | >= 3.0 |

## Recursos

| Nombre | Tipo |
|--------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | recurso |

## Inputs

| Nombre | Descripción | Tipo | Requerido |
|--------|-------------|------|-----------|
| cluster_name | Nombre del clúster ECS | `string` | sí |
| tags | Etiquetas comunes para aplicar al recurso | `map(string)` | sí |

## Outputs

| Nombre | Descripción |
|--------|-------------|
| cluster_id | ID del clúster ECS |
| cluster_arn | ARN del clúster ECS |

## Ejemplos

### Clúster ECS básico

```hcl
module "ecs_cluster_produccion" {
  source = "github.com/KaribuLab/terraform-aws-ecs-cluster"

  cluster_name = "produccion"
  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

## Licencia

Este módulo está licenciado bajo la licencia MIT.

## Autor

Módulo mantenido por KaribuLab. 