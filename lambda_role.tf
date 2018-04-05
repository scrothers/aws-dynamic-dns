variable "cluster_name" {
  type        = "string"
  description = "The URL safe name for the Kubernetes cluster to be created."
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_dyndns" {
  name                  = "${var.cluster_name}-dyndns"
  path                  = "/kubernetes/"
  description           = "IAM role for Lambda DynDNS service."
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = "${aws_iam_role.lambda_dyndns.id}"
  policy = "${data.aws_iam_policy_document.lambda_permissions.json}"
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:route53:::hostedzone/${var.zone_id}",
    ]
  }

  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]

    effect = "Allow"

    resources = [
      "${aws_dynamodb_table.dynamic_dns.arn}",
    ]
  }

  statement {
    actions = [
      "logs:*",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:*:*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeInstances",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}
