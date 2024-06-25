output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_id_output" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "IAM_role_arn_output" {
  description = "The ARN of the IAM role used by the EKS cluster"
  value       = module.eks_iam_role.iam_role_arn
}
