variable "stack_name" {
  type        = string
  description = "Stack name"
}

variable "aws_region" {
  type        = string
  description = "AWS region name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets the cluster is able to use (public and private)"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Enable private cluster endpoint access"
  default     = true
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Enable cluster public cluster endpoint access"
  default     = true
}

variable "cluster_endpoint_public_access_cidr_list" {
  type        = list(string)
  description = "A list of CIDRs able to access the public Kubernetes endpoints"
  default     = ["0.0.0.0/0"]
}

variable "enabled_logs" {
  type        = list(string)
  description = "A list of enabled Kubernetes log types"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_period" {
  type        = number
  description = "Number of days to retain cluster logs for"
  default     = 30
}

variable "vpc_id" {
  description = "VPC ID to deploy the cluster into"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

###############################################################################
# cluster logs
#   - https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
###############################################################################
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.stack_name}/cluster"
  retention_in_days = var.log_retention_period
  tags              = var.tags
}


###############################################################################
# iam config
###############################################################################
data "aws_iam_policy_document" "cluster-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.stack_name}-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster-assume-role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

###############################################################################
# cluster security group
###############################################################################
resource "aws_security_group" "this" {
  name   = "${var.stack_name}-cluster"
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_security_group_rule" "egress_internet" {
  description       = "Allow cluster egress to the Internet"
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

###############################################################################
# cluster configuration
###############################################################################
resource "aws_eks_cluster" "this" {
  name                      = var.stack_name
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = var.enabled_logs
  tags                      = var.tags

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.this.id]

    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidr_list
  }

  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}

###############################################################################
output "status" {
  value = aws_eks_cluster.this.status
}

output "cluster_version" {
  value = aws_eks_cluster.this.version
}

output "platform_version" {
  value = aws_eks_cluster.this.platform_version
}

output "kubeconfig" {
  value = templatefile("${path.module}/kubeconfig.tpl", {
    endpoint            = aws_eks_cluster.this.endpoint
    cluster_auth_base64 = aws_eks_cluster.this.certificate_authority.0.data
    cluster_arn         = aws_eks_cluster.this.arn
    cluster_name        = aws_eks_cluster.this.id
    region              = var.aws_region
  })
}

output "oidc_issuer" {
  value = replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
}