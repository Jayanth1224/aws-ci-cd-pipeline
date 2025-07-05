data "aws_iam_policy_document" "alb_controller_policy_doc" {
  // This is the official policy document recommended by AWS.
  // It grants the controller permissions to manage ALBs, target groups, etc.
  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
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
      "elasticloadbalancing:SetWebAcl",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "tag:GetResources",
      "tag:TagResources",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["waf:GetWebACL"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["wafv2:AssociateWebACL", "wafv2:DisassociateWebACL", "wafv2:GetWebACL", "wafv2:GetWebACLForResource"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "IAM policy for the AWS Load Balancer Controller"
  policy      = data.aws_iam_policy_document.alb_controller_policy_doc.json
}

module "alb_controller_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.0"

  role_name                              = "${var.cluster_name}-alb-controller"
  attach_load_balancer_controller_policy = false // We are attaching our own policy below
  
  role_policy_arns = {
    alb_controller = aws_iam_policy.alb_controller_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}