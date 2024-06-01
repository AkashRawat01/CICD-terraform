data "aws_availability_zones" "azs" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.eks_cluster_name
  depends_on = [ module.eks
]
}