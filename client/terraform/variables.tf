
variable "project" {
  description = "Name of the project"
  type        = string
  default     = "sbahles-beauty-bar"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the GitHub CodeStar connection"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to monitor"
  type        = string
  default     = "main"
}