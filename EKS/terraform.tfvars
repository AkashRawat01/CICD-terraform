vpc_cidr = "10.0.0.0/16"

public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

instance_types = ["t2.medium"]

eks_cluster_name = "dev_eks_cluster"

eks_cluster_vpc = "dev_eks_cluster_vpc"