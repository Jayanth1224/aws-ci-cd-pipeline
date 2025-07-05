module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true 
  enable_dns_hostnames = true


  tags = {
    "Terraform"   = "true"
    "Environment" = "dev"
    "Project"     = "DevOps-Pipeline"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}


data "aws_availability_zones" "available" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1" 
  cluster_name    = var.cluster_name
  cluster_version = "1.33" 


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  enable_irsa = true

  eks_managed_node_groups = {

    main_nodes = {
      min_size     = 1 // Minimum number of nodes
      max_size     = 3 // Maximum number of nodes
      desired_size = 2 // The number of nodes to start with

      instance_types = ["t3.medium"] 
      
    }
  }

  tags = {
    "Terraform"   = "true"
    "Environment" = "dev"
    "Project"     = "DevOps-Pipeline"
  }
}

module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.37.1" 

  manage_aws_auth_configmap = true

  

  aws_auth_users = [
    {
      userarn  = var.iam_user_arn
      username = var.iam_username
      groups   = ["system:masters"]
    },
  ]
}
