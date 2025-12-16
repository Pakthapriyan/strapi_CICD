variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "key_name" {
  type    = string
  default = "paktha-key"
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "app_keys" {
  type = string
}

variable "api_token_salt" {
  type = string
}

variable "admin_jwt_secret" {
  type = string
}
