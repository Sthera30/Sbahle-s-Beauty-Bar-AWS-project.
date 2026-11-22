# This file holds variables that we will be using in our ALB infrastructure

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets where the ALB will be placed"
  type        = list(string)
}