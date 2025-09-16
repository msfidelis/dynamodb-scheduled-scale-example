
# Auto Scaling Target - GSI Read Capacity
resource "aws_appautoscaling_target" "gsi_read_target" {
  max_capacity       = var.read_capacity_max
  min_capacity       = var.read_capacity
  resource_id        = "table/${aws_dynamodb_table.exemplo_tabela.name}/index/GSI-Status-CreatedAt"
  role_arn           = aws_iam_role.dynamodb_autoscaling_role.arn
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Target - GSI Write Capacity
resource "aws_appautoscaling_target" "gsi_write_target" {
  max_capacity       = var.write_capacity_max
  min_capacity       = var.write_capacity
  resource_id        = "table/${aws_dynamodb_table.exemplo_tabela.name}/index/GSI-Status-CreatedAt"
  role_arn           = aws_iam_role.dynamodb_autoscaling_role.arn
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy - GSI Read Capacity (Target Tracking)
resource "aws_appautoscaling_policy" "gsi_read_policy" {
  name               = "${var.table_name}-gsi-read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gsi_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.gsi_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Auto Scaling Policy - GSI Write Capacity (Target Tracking)
resource "aws_appautoscaling_policy" "gsi_write_policy" {
  name               = "${var.table_name}-gsi-write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gsi_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.gsi_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Scheduled Actions para GSI Read Capacity 
resource "aws_appautoscaling_scheduled_action" "gsi_read_scheduled" {
  count = length(var.scheduled_actions_gsi)
  name               = "${var.table_name}-gsi-read-${var.scheduled_actions_gsi[count.index].name}"
  service_namespace  = aws_appautoscaling_target.gsi_read_target.service_namespace
  resource_id        = aws_appautoscaling_target.gsi_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_read_target.scalable_dimension
  schedule           = var.scheduled_actions_gsi[count.index].cron
  timezone           = var.scheduled_actions_gsi[count.index].timezone

  scalable_target_action {
    min_capacity = var.scheduled_actions_gsi[count.index].rcu_min
    max_capacity = var.scheduled_actions_gsi[count.index].rcu_max
  }
}

# Scheduled Actions para GSI Write Capacity 
resource "aws_appautoscaling_scheduled_action" "gsi_write_scheduled" {
  count = length(var.scheduled_actions_gsi)

  name               = "${var.table_name}-gsi-write-${var.scheduled_actions_gsi[count.index].name}"
  service_namespace  = aws_appautoscaling_target.gsi_write_target.service_namespace
  resource_id        = aws_appautoscaling_target.gsi_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_write_target.scalable_dimension
  schedule           = var.scheduled_actions_gsi[count.index].cron
  timezone           = var.scheduled_actions_gsi[count.index].timezone

  scalable_target_action {
    min_capacity = var.scheduled_actions_gsi[count.index].wcu_min
    max_capacity = var.scheduled_actions_gsi[count.index].wcu_max
  }
}