
# Here we are telling AWS to use us-east-1 region
provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source = "./modules/ecr"

  project = var.project
}

module "vpc" {
  source = "./modules/vpc"

  project = var.project

}

module "alb" {
  source = "./modules/alb"

  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs_service" {
  source = "./modules/ecs_service"

  project                 = var.project
  vpc_id                  = module.vpc.vpc_id
  alb_security_group_id   = module.alb.alb_security_group_id
  ecr_repository_url      = module.ecr.repository_url
  private_subnet_ids      = module.vpc.private_subnet_ids
  target_group_arn        = module.alb.target_group_arn

  cluster_arn             = module.ecs_cluster.cluster_arn
  capacity_provider_name  = module.ecs_cluster.capacity_provider_name
}

# Here we are telling terraform to look for the modules folder in its folder 
# Navigate to the ecs_cluster subfolder and build our cluster using the instructions in our terraform files

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  project            = var.project
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}