data "aws_availability_zones" "available" {}

module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = "5.1.1"

	name            = "${var.cluster_name}-vpc"
	cidr            = "10.2.0.0/16"
	azs             = ["us-east-1a", "us-east-1d"]
	private_subnets = ["10.2.64.0/20", "10.2.128.0/20"]
	public_subnets  = ["10.2.16.0/20", "10.2.32.0/20"]

	enable_nat_gateway      = true
	single_nat_gateway      = true
	enable_dns_hostnames    = true
	map_public_ip_on_launch = true
}
