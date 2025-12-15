terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


# FETCH ACCOUNT ID

data "aws_caller_identity" "current" {}

locals {
  ecr_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/paktha-my-strapi-repo"
}


# DEFAULT VPC & SUBNETS
data "aws_vpc" "default" { default = true }

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# SECURITY GROUPS
resource "aws_security_group" "ec2_sg" {
  name        = "paktha-ec2-sg-1"
  description = "Allow Strapi & SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "paktha-rds-sg-1"
  description = "Allow EC2 to reach Postgres"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECR REPOSITORY
resource "aws_ecr_repository" "strapi_repo" {
  name = "paktha-my-strapi-repo-1"
}


# RDS POSTGRES
resource "aws_db_subnet_group" "subnet_group" {
  name       = "paktha-strapi-db-subnets-1"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "strapi_rds" {
  identifier             = "paktha-strapi-postgres"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
}


# EC2 INSTANCE 
data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "strapi" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name = "paktha-key"
user_data = <<EOF
#!/bin/bash
set -xe

exec > /var/log/user-data.log 2>&1

yum update -y
yum install -y docker unzip curl -y

systemctl start docker
systemctl enable docker

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -o /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Create AWS credentials
mkdir -p /root/.aws

cat > /root/.aws/credentials <<CONFIG
[default]
aws_access_key_id=${var.aws_access_key}
aws_secret_access_key=${var.aws_secret_key}
CONFIG

cat > /root/.aws/config <<CONFIG2
[default]
region=${var.aws_region}
CONFIG2

# ECR Login
aws ecr get-login-password --region ${var.aws_region} \
 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

# Pull image
docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/paktha-my-strapi-repo-1:latest

# Wait for RDS to be ready
DB_HOST="${aws_db_instance.strapi_rds.address}"

for i in {1..30}; do
  nc -z -w3 $DB_HOST 5432 && break
  echo "Waiting for RDS..."
  sleep 10
done

# Run Strapi container
docker rm -f strapi || true

docker run -d --restart always --name strapi \
 -p 1337:1337 \
 -e DATABASE_CLIENT=postgres \
 -e DATABASE_HOST=${aws_db_instance.strapi_rds.address} \
 -e DATABASE_PORT=5432 \
 -e DATABASE_NAME=${var.db_name} \
 -e DATABASE_USERNAME=${var.db_username} \
 -e DATABASE_PASSWORD=${var.db_password} \
 ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/paktha-my-strapi-repo-1:latest

# show logs for debugging
docker logs --tail 50 strapi || true
EOF


  tags = { Name = "paktha-strapi-ec2" }
}

