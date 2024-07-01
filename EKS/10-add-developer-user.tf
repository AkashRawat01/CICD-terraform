resource "aws_iam_user" "prod-developer" {
  name = "prod-developer"
}

resource "aws_iam_policy" "developer_eks" {
  name = "AmazonEKSProdDeveloperPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user       = aws_iam_user.prod-developer.name
  policy_arn = aws_iam_policy.developer_eks.arn
}

resource "aws_eks_access_entry" "prod-developer" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_user.prod-developer.arn
  kubernetes_groups = ["my-viewer"]
}