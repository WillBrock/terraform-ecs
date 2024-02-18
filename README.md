# Basic ECS Terraform code for PHP and Nginx

## Build the ECS infrastructure

Update the variables in dev.tfvars to fit your needs

```bash
terraform apply
```

## Build docker images using dockerx

This will build, tag and push the new image to you ECR repo

Build nginx image
```bash
docker buildx build --platform linux/amd64 -t <account number>.dkr.ecr.us-east-1.amazonaws.com/<image name>:latest --push ./docker-nginx
```

Build php image
```bash
docker buildx build --platform linux/amd64 -t <account number>.dkr.ecr.us-east-1.amazonaws.com/<image name>:latest --push ./docker-php
```

## Force a new deployment

Nginx
```bash
aws ecs update-service --cluster <your cluster name> --service nginx-service --force-new-deployment
```

PHP
```bash
aws ecs update-service --cluster <your cluster name> --service php-service --force-new-deployment
```
