resource "aws_security_group" "nginx_sg" {
	vpc_id = module.vpc.vpc_id

	ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port   = 443
		to_port     = 443
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "nginx_sg"
	}
}

resource "aws_security_group" "php_sg" {
	vpc_id = module.vpc.vpc_id

	ingress {
		from_port       = 9000
		to_port         = 9000
		protocol        = "tcp"
		# security_groups = [aws_security_group.nginx_sg.id]
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "php_sg"
	}
}
