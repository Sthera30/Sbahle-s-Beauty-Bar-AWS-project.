# Tells terraform which version of itself to use and which plugin to use
# e.g AWS, Azure or GCP

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
