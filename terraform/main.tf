terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "suffix" {
  byte_length = 2
}

# -------------------------
# SECURITY GROUP
# -------------------------
resource "aws_security_group" "strapi_sg" {
  name        = "paktha-strapi-sg-${random_id.suffix.hex}"
  description = "Allow SSH and Strapi"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
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

# -------------------------
# AMI
# -------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -------------------------
# EC2 INSTANCE
# -------------------------
resource "aws_instance" "strapi" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  root_block_device {
    volume_size = 30
  }

  user_data_replace_on_change = false

  user_data = templatefile("${path.module}/user_data.tpl", {
    image_name        = var.image_name
    image_tag         = var.image_tag
    app_keys          = var.app_keys
    api_token_salt    = var.api_token_salt
    admin_jwt_secret = var.admin_jwt_secret
  })

  tags = {
    Name = "paktha-strapi-task6"
  }
}
