# Fetching existing IAM role
data "aws_iam_role" "existing_iam_role" {
  name = "akash_ec2_access_eks_aws"
}

# Attaching Custom EKS Admin policy to Existing IAM role
resource "aws_iam_role_policy_attachment" "eks_admin_akash" {
  role       = data.aws_iam_role.existing_iam_role.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_eks_access_entry" "eks_admin_akash" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = data.aws_iam_role.existing_iam_role.arn
  kubernetes_groups = ["my-admin"]
}
