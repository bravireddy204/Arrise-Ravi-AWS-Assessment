# This file shows the corrected trust policy and bucket permissions.
# roleB must exist in Account A and the shared bucket must exist in Account B.
# Account B provider credentials are required.

# The Account B trust names the exact role created above.
data "aws_iam_policy_document" "role_c_trust" {
  provider = aws.account_b

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::000000000000:role/roleB"]
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
