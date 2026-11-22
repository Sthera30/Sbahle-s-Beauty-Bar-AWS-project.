
# Here we are creating our ECR Repo
# This is the Repo we will be using to store our Docker image

resource "aws_ecr_repository" "this" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true # we don't want our ECR to refuse to let our image go when we run terraform destroy

  tags = {
    Name = "${var.project}-ecr"
  }
}