terraform {
  backend "s3" {
    key = "ravi-assessment/terraform.tfstate"
    encrypt = true
    # Supply bucket, region and dynamodb_table with -backend-config=backend.hcl
  }
}
