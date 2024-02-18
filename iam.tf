
resource "aws_iam_role" "ecs_task_execution_role" {
	name = "ecs_task_execution_role"

	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = "sts:AssumeRole"
				Principal = {
					Service = "ecs-tasks.amazonaws.com"
				}
				Effect = "Allow"
				Sid    = ""
			},
		]
	})
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
	role       = aws_iam_role.ecs_task_execution_role.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_logging_policy_attachment" {
	role       = aws_iam_role.ecs_task_execution_role.name
	policy_arn = aws_iam_policy.ecs_logging_policy.arn
}

resource "aws_iam_policy" "ecs_logging_policy" {
	name        = "ecs_logging_policy"
	description = "Allows ECS tasks to send logs to CloudWatch"

	policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Effect = "Allow",
				Action = [
					"logs:CreateLogStream",
					"logs:PutLogEvents",
					"logs:CreateLogGroup"
				],
				Resource = "arn:aws:logs:*:*:*"
			},
		]
	})
}
