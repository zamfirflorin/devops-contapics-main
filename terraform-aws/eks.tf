module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  authentication_mode = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

# Aici adaugi accesul pentru tine sau echipa ta
  access_entries = {

    admin_user = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::512740826847:role/eks-role" # ARN de IAM

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }

    # technical_user = {
    #   kubernetes_groups = []
    #   principal_arn     = "arn:aws:iam::512740826847:user/technical-user" # ARN de IAM

    #   policy_associations = {
    #     admin = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    #       access_scope = {
    #         type       = "cluster"
    #       }
    #     }
    #   }
    # }
  }

  cluster_endpoint_public_access = true

  # Disable CloudWatch logging to avoid permissions issues
  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  # Disable KMS encryption to avoid permissions issues
  create_kms_key = false
  cluster_encryption_config = []

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      ami_type      = "AL2_x86_64"
    }
  }

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}