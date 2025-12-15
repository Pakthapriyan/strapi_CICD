variable "aws_region" {
  type = string
}

variable "key_name" {
  type = string
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
