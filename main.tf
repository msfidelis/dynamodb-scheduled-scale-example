# Configuração do provider AWS
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Tabela DynamoDB principal
resource "aws_dynamodb_table" "exemplo_tabela" {
  name         = var.table_name
  billing_mode = "PROVISIONED"
  hash_key     = "id" # Chave primária (partition key)
  range_key    = "sk" # Chave de ordenação (sort key)

  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  attribute {
    name = "gsi_id"
    type = "S"
  }

  attribute {
    name = "gsi_sk"
    type = "N"
  }

  # Global Secondary Index (GSI)
  global_secondary_index {
    name      = "GSI-Status-CreatedAt"
    hash_key  = "gsi_id"
    range_key = "gsi_sk"

    read_capacity  = var.read_capacity
    write_capacity = var.write_capacity

    projection_type = "ALL" # Projeta todos os atributos

  }

  dynamic "ttl" {
    for_each = var.enable_ttl ? [1] : []
    content {
      attribute_name = "expires_at"
      enabled        = true
    }
  }

  # Tags
  tags = merge(
    {
      Name      = var.table_name
      Project   = "DynamoDB Autoscaling"
      CreatedBy = "Terraform"
    },
    var.tags
  )
}


