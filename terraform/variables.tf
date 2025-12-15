variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "aws_access_key" { type = string }
variable "aws_secret_key" { type = string }

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_name" {
  type    = string
  default = "strapidb"
}

variable "db_username" {
  type    = string
  default = "strapi"
}

variable "db_password" {
  type      = string
  sensitive = true
}
