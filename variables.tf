variable "container_port" {
  default = 3000
}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  default = "dev"
}

variable "fg_mem" {
  default = 512
}

variable "fg_cpu" {
  default = 256
}

variable "ecr_repo" {
  default = "ab-blog-app"
}