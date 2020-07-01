resource "random_id" "this" {
  special = false
  length  = 8
}

data "aws_ami" "eks-worker" {
  most_recent = true
  name_regex  = "^amazon-eks-node-[1-9,\\.]+-v\\d{8}$"
  owners      = ["602401143452"]

  filter {
    name = "name"
    values = ["amazon-eks-node-*"]
  }
}

data "aws_iam_policy_document" "assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.stack_name}-self-managed-${random_id.this.result}"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.stack_name}-self-managed-${random_id.this.result}"
  role = aws_iam_role.this.name
}

resource "aws_security_group" "this" {
  name        = "${var.stack_name}-self-managed-${random_id.this.result}"
  description = "EKS worker nodes security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "egress-all" {
  type                     = "egress"
  description              = "Allow worker nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress-control-plane" {
  type = "ingress"
  description = "Allow communicaton from the control plane"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = aws_security_group.this.id
  source_security_group_id = aws_security_group.this.id
}

