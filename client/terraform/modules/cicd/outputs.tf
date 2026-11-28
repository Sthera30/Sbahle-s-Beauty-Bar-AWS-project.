
output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.this.arn
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.app.name
}

output "codebuild_role_arn" {
  description = "IAM role assumed by CodeBuild"
  value       = aws_iam_role.codebuild.arn
}

output "pipeline_role_arn" {
  description = "IAM role assumed by CodePipeline"
  value       = aws_iam_role.pipeline.arn
}

output "artifacts_bucket_name" {
  description = "S3 bucket used to store pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_registry" {
  description = "ECR registry used by CodeBuild"
  value       = local.ecr_registry
}

output "ecr_repository_name" {
  description = "ECR repository used for Docker images"
  value       = var.ecr_repository_name
}

output "ecs_cluster_name" {
  description = "ECS cluster targeted by the deployment stage"
  value       = var.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service targeted by the deployment stage"
  value       = var.ecs_service_name
}
