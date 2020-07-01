resource "kubernetes_namespace" "aws-alb-ingress" {
  metadata {
    name = "aws-alb-ingress"
  }
}

data "aws_iam_policy_document" "aws-alb-ingress-controller" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["cognito-idp:DescribeUserPoolClient"]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "tag:GetResources",
      "tag:TagResources",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["waf:GetWebACL"]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections",
    ]
  }
}

resource "aws_iam_policy" "aws-alb-ingress-controller" {
  name_prefix = "aws-alb-ingress-controller"
  policy      = data.aws_iam_policy_document.aws-alb-ingress-controller.json
}

module "alb-ingress-controller-iam-role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "alb-ingress-controller.${var.stack_name}"
  provider_url                  = var.oidc_issuer
  role_policy_arns              = [aws_iam_policy.aws-alb-ingress-controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:ingress:aws-alb-ingress-controller"]
}

resource "helm_release" "aws-alb-ingress-controller" {
  name       = "aws-alb-ingress-controller"
  chart      = "aws-alb-ingress-controller"
  repository = local.helm_repo["incubator"]
  namespace  = kubernetes_namespace.aws-alb-ingress.metadata.0.name

  set {
    name  = "clusterName"
    value = var.stack_name
  }

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb-ingress-controller-iam-role.this_iam_role_arn
  }
}