# DynamoDB Scheduled Auto Scaling - Terraform

Este projeto implementa uma solução completa de **autoscaling agendado** para tabelas DynamoDB usando Application Auto Scaling da AWS. 

O objetivo é ilustrar como configurar warm-up automático baseado em horários específicos tanto para a tabela principal quanto para Global Secondary Indexes (GSI) para suprir capacity repentinos em picos de acesso conhecidos.



```mermaid
graph TB
    A[Scheduled Actions] --> B{Horário<br/>Atingido?}
    
    B -->|Sim| C[Application Auto Scaling<br/>Ajusta Capacidades]
    B -->|Não| D[Aguarda Próximo<br/>Horário]
    
    C --> E[DynamoDB Table]
    C --> F[GSI Index]
    
    E --> G[Read Capacity<br/>WarmUp/Down]
    E --> H[Write Capacity<br/>WarmUp/Down]
    
    F --> I[GSI Read Capacity<br/>WarmUp/Down]
    F --> J[GSI Write Capacity<br/>WarmUp/Down]
    
    G --> K[Target Tracking<br/>Monitora Utilização X%]
    H --> K
    I --> L[Target Tracking GSI<br/>Monitora Utilização X%]
    J --> L
    
    K --> M[Auto Scale Up/Down<br/>]
    L --> M
    
 
    
    D --> B
    
    style A fill:#e1f5fe
    style C fill:#f3e5f5
    style E fill:#e8f5e8
    style F fill:#e8f5e8
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.gsi_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.gsi_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.table_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.table_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.gsi_read_scheduled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.gsi_write_scheduled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.table_read_scheduled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.table_write_scheduled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.gsi_read_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.gsi_write_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.table_read_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.table_write_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_dynamodb_table.exemplo_tabela](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_role.dynamodb_autoscaling_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.dynamodb_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_enable_ttl"></a> [enable\_ttl](#input\_enable\_ttl) | n/a | `bool` | `true` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | n/a | `number` | `5` | no |
| <a name="input_read_capacity_max"></a> [read\_capacity\_max](#input\_read\_capacity\_max) | n/a | `number` | `50` | no |
| <a name="input_scheduled_actions_gsi"></a> [scheduled\_actions\_gsi](#input\_scheduled\_actions\_gsi) | Lista de ações agendadas para warm-up/scale do GSI | <pre>list(object({<br/>    name     = string<br/>    rcu_min  = number<br/>    rcu_max  = number<br/>    wcu_min  = number<br/>    wcu_max  = number<br/>    cron     = string<br/>    timezone = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cron": "cron(07 17 * * ? *)",<br/>    "name": "peak test warmup",<br/>    "rcu_max": 30,<br/>    "rcu_min": 20,<br/>    "timezone": "America/Sao_Paulo",<br/>    "wcu_max": 30,<br/>    "wcu_min": 20<br/>  },<br/>  {<br/>    "cron": "cron(30 15 * * ? *)",<br/>    "name": "peak test warmdown",<br/>    "rcu_max": 10,<br/>    "rcu_min": 5,<br/>    "timezone": "America/Sao_Paulo",<br/>    "wcu_max": 10,<br/>    "wcu_min": 5<br/>  }<br/>]</pre> | no |
| <a name="input_scheduled_actions_table"></a> [scheduled\_actions\_table](#input\_scheduled\_actions\_table) | Lista de ações agendadas para warm-up/scale da tabela DynamoDB | <pre>list(object({<br/>    name     = string<br/>    rcu_min  = number<br/>    rcu_max  = number<br/>    wcu_min  = number<br/>    wcu_max  = number<br/>    cron     = string<br/>    timezone = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cron": "cron(58 14 * * ? *)",<br/>    "name": "peak test warmup",<br/>    "rcu_max": 30,<br/>    "rcu_min": 20,<br/>    "timezone": "America/Sao_Paulo",<br/>    "wcu_max": 30,<br/>    "wcu_min": 20<br/>  },<br/>  {<br/>    "cron": "cron(30 15 * * ? *)",<br/>    "name": "peak test warmdown",<br/>    "rcu_max": 10,<br/>    "rcu_min": 5,<br/>    "timezone": "America/Sao_Paulo",<br/>    "wcu_max": 10,<br/>    "wcu_min": 5<br/>  }<br/>]</pre> | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | n/a | `string` | `"example-autoscaling"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | n/a | `number` | `5` | no |
| <a name="input_write_capacity_max"></a> [write\_capacity\_max](#input\_write\_capacity\_max) | n/a | `number` | `50` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->