variable "cluster_name" {
	default = "will-test"
}

variable "region" {
	default = "us-east-1"
}

variable "logs_group" {
	default = "/ecs/will-test"
}

variable "nginx_ecr_repository_url" {
	default = "<account number>.dkr.ecr.us-east-1.amazonaws.com/will-nginx:latest"
}

variable "php_ecr_repository_url" {
	default = "<account number>.dkr.ecr.us-east-1.amazonaws.com/will-php:latest"
}

