variable "stack_name" {
  type        = string
  description = "Stack name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets the Fargate pods should be scheduled in"
}

variable "fargate_profile_selector" {
  type = list(object({
    namespace = string
    labels    = map(string)
  }))

  description = "A list of selectors"

  default = [
    {
      namespace = "kube-system",
      labels = {}
    },
  ]
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

resource "random_id" "this" {
  special = false
  length  = 8
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.stack_name}-fargate-${random_id.this.id}"
  assume_role_policy = data.aws_iam_policy_document.fargate-assume-role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_eks_fargate_profile" "this" {
  cluster_name           = var.stack_name
  fargate_profile_name   = random_id.this.result
  pod_execution_role_arn = aws_iam_role.this.arn
  subnet_ids             = var.subnet_ids
  tags                   = var.tags

  dynamic "selector" {
    for_each = var.fargate_profile_selector

    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }
}

output "arn" {
  value = aws_eks_fargate_profile.this.arn
}

output "status" {
  value = aws_eks_fargate_profile.this.status
}