variable "kube_version" {
  type    = string
  default = "1.18"
}

variable "worker_group_size" {
  type    = number
  default = 3
}

variable "max_spot_price" {
  type    = string
  default = "0.250"
}

variable "instance_type" {
  type    = string
  default = "c4.xlarge"
}

variable "cluster_name" {
  type    = string
  default = "sre-infra"
}

locals {
  cluster_name = var.cluster_name
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = var.kube_version
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "test"
    Owners      = "sre"
  }

  worker_groups = [
    {
      name                          = "${local.cluster_name}-spot-worker-group-1"
      asg_desired_capacity          = var.worker_group_size
      spot_price                    = var.max_spot_price
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      instance_type                 = var.instance_type
      kubelet_extra_args            = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes           = ["AZRebalance"]
      root_volume_type              = "gp2"
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
}
