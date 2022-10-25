provider "aws" {
  version = "~> 2.0"
  region  = var.region
  profile = "container_project"
  #profile = "default"
}



# data "aws_ecr_repository" "service" {
#   name = "ahmed-bill-app-container"
# }

# data "aws_ecr_repository" "service" {
#   name = "express-hello-world"
# }

data "aws_ecr_repository" "service" {
  name = "ab-blog-app"
}
