# Variáveis para configuração da infraestrutura DynamoDB

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "table_name" {
  type    = string
  default = "example-autoscaling"

  validation {
    condition     = length(var.table_name) > 3 && length(var.table_name) <= 255
    error_message = "O nome da tabela deve ter entre 3 e 255 caracteres."
  }
}

variable "read_capacity" {
  type    = number
  default = 5
}

variable "read_capacity_max" {
  type    = number
  default = 50
}

variable "write_capacity" {
  type    = number
  default = 5
}

variable "write_capacity_max" {
  type    = number
  default = 50
}

variable "enable_ttl" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "scheduled_actions_table" {
  description = "Lista de ações agendadas para warm-up/scale da tabela DynamoDB"
  type = list(object({
    name     = string
    rcu_min  = number
    rcu_max  = number
    wcu_min  = number
    wcu_max  = number
    cron     = string
    timezone = string
  }))
  default = [
    {
      name     = "peak test warmup"
      rcu_min  = 20
      rcu_max  = 30
      wcu_min  = 20
      wcu_max  = 30
      cron     = "cron(58 14 * * ? *)"
      timezone = "America/Sao_Paulo"
    },
    {
      name     = "peak test warmdown"
      rcu_min  = 5
      rcu_max  = 10
      wcu_min  = 5
      wcu_max  = 10
      cron     = "cron(30 15 * * ? *)"
      timezone = "America/Sao_Paulo"
    },
  ]
}

variable "scheduled_actions_gsi" {
  description = "Lista de ações agendadas para warm-up/scale do GSI "
  type = list(object({
    name     = string
    rcu_min  = number
    rcu_max  = number
    wcu_min  = number
    wcu_max  = number
    cron     = string
    timezone = string
  }))
  default = [
    {
      name     = "peak test warmup"
      rcu_min  = 20
      rcu_max  = 30
      wcu_min  = 20
      wcu_max  = 30
      cron     = "cron(07 17 * * ? *)"
      timezone = "America/Sao_Paulo"
    },
    {
      name     = "peak test warmdown"
      rcu_min  = 5
      rcu_max  = 10
      wcu_min  = 5
      wcu_max  = 10
      cron     = "cron(30 15 * * ? *)"
      timezone = "America/Sao_Paulo"
    },
  ]
}