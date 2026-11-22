variable "project" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS EC2 instances will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets where ECS EC2 instances will be launched"
  type        = list(string)
}