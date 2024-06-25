# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Data Source for Availability Zones
data "aws_availability_zones" "azs" {}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = var.eks_cluster_vpc
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/private_elb"                = 1
  }
}

# IAM Role and Policies for EKS Cluster
module "eks_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "4.7.0"

  name = "akash_user_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ECRAccessPolicy"
  description = "Policy to allow EKS to pull images from ECR"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_ecr_access" {
  role       = module.eks_iam_role.iam_role_name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# EKS Cluster
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "18.26.0"
  cluster_name                   = var.eks_cluster_name
  cluster_version                = "1.30"
  cluster_endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = var.instance_types
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  # Ensure node groups are deleted before the cluster
  lifecycle {
    ignore_changes = [cluster_name]
  }

  depends_on = [
    module.vpc,
    aws_iam_role_policy_attachment.eks_ecr_access
  ]
}

# Kubernetes Config Map for AWS Auth
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks_iam_role.iam_role_arn
        username = "akash-user"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks]
}

# Outputs
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_id_output" {
  value = module.eks.cluster_id
}

output "IAM_role_arn_output" {
  value = module.eks_iam_role.iam_role_arn
}
