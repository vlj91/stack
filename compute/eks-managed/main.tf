variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "instance_type" {
  description = "AWS EC2 instance type to use"
  type        = string
  default     = "t3.medium"
}

variable "instance_disk_size" {
  description = "EBS volume size attached to each instance"
  type        = number
  default     = 50
}

variable "desired_nodes" {
  description = "Initial desired number of nodes. This number is ignored after initial deployment"
  type        = number
  default     = 3
}

variable "min_nodes" {
  description = "Initial minimum number of nodes. This number is ignored after initial deployment"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Initial number of maximum nodes. This number is ignored after initial deployment"
  type        = number
  default     = 5
}

variable "subnet_ids" {
  description = "A list of subnet IDs to deploy the nodes into"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

resource "random_string" "id" {
  length  = 8
  special = false
}

data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.stack_name}-nodes-${random_string.id.result}"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.stack_name
  node_group_name = random_string.id.result
  instance_types  = [var.instance_type]
  disk_size       = var.instance_disk_size
  node_role_arn   = aws_iam_role.this.arn
  subnet_ids      = var.subnet_ids
  tags            = var.tags

  scaling_config {
    desired_size = var.desired_nodes
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  lifecycle {
    ignore_changes = [scaling_config]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

output "node_group_arn" {
  value = aws_eks_node_group.this.arn
}

output "node_group_id" {
  value = aws_eks_node_group.this.id
}

output "node_group_status" {
  value = aws_eks_node_group.this.status
}