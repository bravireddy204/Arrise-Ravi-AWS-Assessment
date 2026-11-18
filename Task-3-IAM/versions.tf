terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "6.38.0" }
  }
}
provider "aws" {
  region = var.region
  allowed_account_ids = [var.account_a_id]
}
provider "aws" {
  alias = "account_b"
  region = var.region
  profile = var.account_b_profile
  allowed_account_ids = [var.account_b_id]
}
