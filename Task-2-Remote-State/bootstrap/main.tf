terraform {
  required_version = "~> 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
  }
}

variable "account_a_id" {
  type    = string
  default = "000000000000"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_a_id]
}

resource "aws_s3_bucket" "state" {
  bucket_prefix = "ravi-assessment-state-"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "locks" {
  name         = "ravi-assessment-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "backend_config" {
  description = "Save this output as backend.hcl when initializing the main configuration."
  value       = <<-HCL
    bucket              = "${aws_s3_bucket.state.bucket}"
    region              = "${var.region}"
    dynamodb_table      = "${aws_dynamodb_table.locks.name}"
    allowed_account_ids = ["${var.account_a_id}"]
  HCL
}
