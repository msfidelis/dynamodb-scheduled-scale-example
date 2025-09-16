
# Application Auto Scaling para DynamoDB

# Auto Scaling Target - Table Read Capacity
resource "aws_appautoscaling_target" "table_read_target" {
  max_capacity       = var.read_capacity_max
  min_capacity       = var.read_capacity
  resource_id        = "table/${aws_dynamodb_table.exemplo_tabela.name}"
  role_arn           = aws_iam_role.dynamodb_autoscaling_role.arn
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Target - Table Write Capacity
resource "aws_appautoscaling_target" "table_write_target" {
  max_capacity       = var.write_capacity_max
  min_capacity       = var.write_capacity
  resource_id        = "table/${aws_dynamodb_table.exemplo_tabela.name}"
  role_arn           = aws_iam_role.dynamodb_autoscaling_role.arn
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy - Table Read Capacity (Target Tracking)
resource "aws_appautoscaling_policy" "table_read_policy" {
  name               = "${var.table_name}-table-read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Auto Scaling Policy - Table Write Capacity (Target Tracking)
resource "aws_appautoscaling_policy" "table_write_policy" {
  name               = "${var.table_name}-table-write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Scheduled Actions para Read Capacity 
resource "aws_appautoscaling_scheduled_action" "table_read_scheduled" {
  count = length(var.scheduled_actions_table)

  name               = "${var.table_name}-read-${var.scheduled_actions_table[count.index].name}"
  service_namespace  = aws_appautoscaling_target.table_read_target.service_namespace
  resource_id        = aws_appautoscaling_target.table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.table_read_target.scalable_dimension
  schedule           = var.scheduled_actions_table[count.index].cron
  timezone           = var.scheduled_actions_table[count.index].timezone

  scalable_target_action {
    min_capacity = var.scheduled_actions_table[count.index].rcu_min
    max_capacity = var.scheduled_actions_table[count.index].rcu_max
  }
}

# Scheduled Actions para Write Capacity 
resource "aws_appautoscaling_scheduled_action" "table_write_scheduled" {
  count = length(var.scheduled_actions_table)

  name               = "${var.table_name}-write-${var.scheduled_actions_table[count.index].name}"
  service_namespace  = aws_appautoscaling_target.table_write_target.service_namespace
  resource_id        = aws_appautoscaling_target.table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.table_write_target.scalable_dimension
  schedule           = var.scheduled_actions_table[count.index].cron
  timezone           = var.scheduled_actions_table[count.index].timezone

  scalable_target_action {
    min_capacity = var.scheduled_actions_table[count.index].wcu_min
    max_capacity = var.scheduled_actions_table[count.index].wcu_max
  }
}
