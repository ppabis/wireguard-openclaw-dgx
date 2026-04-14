data "aws_caller_identity" "X" {}
data "aws_region" "X" {}

data "aws_iam_policy_document" "wireguard_ssm_policy" {
  statement {
    actions   = ["ssm:PutParameter"]
    resources = ["arn:aws:ssm:${data.aws_region.X.region}:${data.aws_caller_identity.X.account_id}:parameter/wireguard/public-key"]
  }
}

resource "aws_iam_role_policy" "wireguard_ssm_policy" {
  name   = "wg-ssm-policy"
  role   = aws_iam_role.wireguard.id
  policy = data.aws_iam_policy_document.wireguard_ssm_policy.json
}

data "aws_iam_policy_document" "wireguard_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "wireguard" {
  name               = "wg-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.wireguard_assume_role_policy.json
}

resource "aws_iam_instance_profile" "wireguard" {
  name = "wg-ec2-profile"
  role = aws_iam_role.wireguard.name
}