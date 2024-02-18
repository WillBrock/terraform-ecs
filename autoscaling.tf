resource "aws_appautoscaling_target" "ecs_service" {
	for_each           = toset(local.services)
	max_capacity       = 10
	min_capacity       = 1
	resource_id        = "service/${var.cluster_name}/${each.key}-service"
	scalable_dimension = "ecs:service:DesiredCount"
	service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out" {
	for_each           = toset(local.services)
	name               = "${var.cluster_name}-scale-out"
	policy_type        = "TargetTrackingScaling"
	resource_id        = aws_appautoscaling_target.ecs_service[each.key].resource_id
	scalable_dimension = aws_appautoscaling_target.ecs_service[each.key].scalable_dimension
	service_namespace  = aws_appautoscaling_target.ecs_service[each.key].service_namespace

	target_tracking_scaling_policy_configuration {
		target_value       = 80.0  # Target CPU utilization (80%)
		scale_in_cooldown  = 300   # Scale in after 5 minutes
		scale_out_cooldown = 300   # Scale out after 5 minutes

		predefined_metric_specification {
			predefined_metric_type = "ECSServiceAverageCPUUtilization"
		}
	}
}

resource "aws_appautoscaling_policy" "scale_in" {
	for_each           = toset(local.services)
	name               = "${var.cluster_name}-scale-in"
	policy_type        = "TargetTrackingScaling"
	resource_id        = aws_appautoscaling_target.ecs_service[each.key].resource_id
	scalable_dimension = aws_appautoscaling_target.ecs_service[each.key].scalable_dimension
	service_namespace  = aws_appautoscaling_target.ecs_service[each.key].service_namespace

	target_tracking_scaling_policy_configuration {
		target_value       = 20.0  # Lower target CPU utilization (20%)
		scale_in_cooldown  = 300
		scale_out_cooldown = 300

		predefined_metric_specification {
			predefined_metric_type = "ECSServiceAverageCPUUtilization"
		}
	}
}
