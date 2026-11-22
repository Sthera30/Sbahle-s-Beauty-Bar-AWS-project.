
# This file holds variables that our VPC infrastructure will use

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

# Here you should have exactly two public subnet cidrs

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "You must provide exactly two public subnet CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  # Here you should have exactly two private subnet cidrs

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "You must provide exactly two private subnet CIDR blocks."
  }
}
