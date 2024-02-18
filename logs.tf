resource "aws_cloudwatch_log_group" "logs_group" {
	name = local.logs_group
}
