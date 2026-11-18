# Account A lets the named people assume these roles through their group2 policy.
data "aws_iam_policy_document" "human_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [for name in local.groups.group2 : aws_iam_user.member[name].arn]
    }
  }
}

resource "aws_iam_role" "role_a" {
  name               = "roleA"
  assume_role_policy = data.aws_iam_policy_document.human_trust.json
}

resource "aws_iam_role_policy" "role_a_services" {
  name = "admin-except-iam"
  role = aws_iam_role.role_a.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        NotAction = "iam:*"
        Resource  = "*"
      },
      {
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "role_b" {
  name               = "roleB"
  assume_role_policy = data.aws_iam_policy_document.human_trust.json
}

# This is roleB's only permission. Its destination is in Account B.
resource "aws_iam_role_policy" "role_b_assume_c" {
  name = "assume-only-roleC"
  role = aws_iam_role.role_b.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.role_c.arn
    }]
  })
}

# The Account B trust names the exact role created above.
data "aws_iam_policy_document" "role_c_trust" {
  provider = aws.account_b

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.role_b.arn]
    }
  }
}

resource "aws_iam_role" "role_c" {
  provider           = aws.account_b
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.role_c_trust.json
}

resource "aws_s3_bucket" "shared" {
  provider = aws.account_b
  bucket   = "ravi-${var.account_b_id}-shared-files"
}

resource "aws_s3_bucket_public_access_block" "shared" {
  provider                = aws.account_b
  bucket                  = aws_s3_bucket.shared.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role_policy" "role_c_s3" {
  provider = aws.account_b
  name     = "full-access-to-shared-files"
  role     = aws_iam_role.role_c.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:*"
      Resource = [
        aws_s3_bucket.shared.arn,
        "${aws_s3_bucket.shared.arn}/*"
      ]
    }]
  })
}
