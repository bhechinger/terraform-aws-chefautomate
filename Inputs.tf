# EC2
variable "ssh_key" {}

variable "key_name" {}
variable "subnet_id" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "volume_size" {
  default = 30
}

variable "volume_type" {
  default = "gp2"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "tags" {
  default = {}
}

# Chef
variable "admin_password" {}

variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "admin_user" {}
variable "admin_firstname" {}
variable "admin_lastname" {}
variable "admin_email" {}
variable "chef_organization" {}

variable "automate_enterprise" {
  default = "default"
}

variable "upgrade_chef" {
  default = true
}

# GetSSL (Let's Encrypt)
variable "getssl_email" {}

variable "account_key" {}
variable "san_list" {}

variable "prod_ca" {
  default = false
}

# Multiple
variable "fqdn" {}
