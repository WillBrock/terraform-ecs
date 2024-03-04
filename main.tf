terraform {
	required_version = ">= 1.0.0"
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = ">= 5.0.0"
		}
	}
}

provider "aws" {
	region = "us-east-1"
}

locals {
	services = ["nginx", "php"]
}

resource "aws_ecs_cluster" "my_cluster" {
	name = var.cluster_name
}

resource "aws_ecs_task_definition" "nginx" {
	family                   = "nginx"
	network_mode             = "awsvpc"
	cpu                      = "2048"
	memory                   = "4096"
	requires_compatibilities = ["FARGATE"]
	execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

	container_definitions = jsonencode([
		{
			name      = "nginx"
			image     = var.nginx_ecr_repository_url
			essential = true
			cpu       = 2048
			memory    = 4096
			portMappings = [
				{
					containerPort = 80
					hostPort      = 80
					protocol      = "tcp"
				},
			]

			logConfiguration = {
				logDriver = "awslogs"
				options = {
					"awslogs-group"         = var.logs_group
					"awslogs-region"        = var.region
					"awslogs-stream-prefix" = "nginx"
				}
			}
		},
	])
}

resource "aws_ecs_task_definition" "php" {
	family                   = "php"
	network_mode             = "awsvpc"
	cpu                      = "2048"
	memory                   = "4096"
	requires_compatibilities = ["FARGATE"]
	execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

	container_definitions = jsonencode([
		{
			name      = "php"
			image     = var.php_ecr_repository_url
			essential = true
			cpu       = 2048
			memory    = 4096

			logConfiguration = {
				logDriver = "awslogs"
				options = {
					"awslogs-group"         = var.logs_group
					"awslogs-region"        = var.region
					"awslogs-stream-prefix" = "php"
				}
			}
		}
	])
}

resource "aws_ecs_service" "nginx_service" {
	name                 = "nginx-service"
	cluster              = aws_ecs_cluster.my_cluster.id
	task_definition      = aws_ecs_task_definition.nginx.arn
	launch_type          = "FARGATE"
	desired_count        = 5
	force_new_deployment = true

	network_configuration {
		subnets          = module.vpc.private_subnets
		security_groups  = [aws_security_group.nginx_sg.id]
		assign_public_ip = false
	}

	load_balancer {
		target_group_arn = aws_lb_target_group.nginx_tg.arn
		container_name   = "nginx"
		container_port   = 80
	}

	service_registries {
		registry_arn = aws_service_discovery_service.nginx.arn
	}
}

resource "aws_ecs_service" "php_service" {
	name                 = "php-service"
	cluster              = aws_ecs_cluster.my_cluster.id
	task_definition      = aws_ecs_task_definition.php.arn
	launch_type          = "FARGATE"
	desired_count        = 1
	force_new_deployment = true

	network_configuration {
		subnets          = module.vpc.private_subnets
		security_groups  = [aws_security_group.php_sg.id]
		assign_public_ip = false
	}

	service_registries {
		registry_arn = aws_service_discovery_service.php_fpm.arn
	}
}

resource "aws_lb" "nginx_lb" {
	name               = "nginx-lb"
	internal           = false
	subnets            = module.vpc.public_subnets
	security_groups    = [aws_security_group.nginx_sg.id]
	load_balancer_type = "application"
}

resource "aws_lb_target_group" "nginx_tg" {
	name        = "nginx-tg"
	port        = 80
	protocol    = "HTTP"
	vpc_id      = module.vpc.vpc_id
	target_type = "ip"
}

resource "aws_lb_listener" "nginx_listener" {
	load_balancer_arn = aws_lb.nginx_lb.arn
	port              = "80"
	default_action {
		type             = "forward"
		target_group_arn = aws_lb_target_group.nginx_tg.arn
	}
}
