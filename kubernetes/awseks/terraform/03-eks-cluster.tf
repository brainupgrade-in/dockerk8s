module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = false

    # Disabling and using externally provided security groups
    create_security_group = false
    create_node_security_group = false

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3a.medium"]

      min_size     = var.cluster_min_size
      max_size     = var.cluster_max_size
      desired_size = var.cluster_desired_size
      capacity_type = "SPOT"
    }

  }
}