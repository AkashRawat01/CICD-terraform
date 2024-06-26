data "aws_eks_cluster" "cluster" {
  name       = var.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name       = var.eks_cluster_name
  depends_on = [module.eks]
}
