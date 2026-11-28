## Use the already established github connection for accessing our github repo

variable "project" {
  type = string
}

 variable "aws_region" {
  type = string
}

 variable "ecr_repository_name" {
  type = string
}

 variable "ecs_cluster_name" {
  type = string
}

 variable "ecs_service_name" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the Available GitHub connection from Lab 8.2" # Put your arn connection here
}

## Tells the CodePipeLine which Github Repository to retrieve the source the code from

variable "github_repository" {
  type        = string
  description = "GitHub owner/repo, e.g. myuser/accelerator" # put your github repo here
}

## Tells the CodePipeLine which branch inside the Github Repo it should monitor and retrieve the code from

variable "github_branch" {
  type    = string
  default = "main"
}