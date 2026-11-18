variable "account_a_id" { type = string; default = "000000000000" }
variable "account_b_id" { type = string; default = "111111111111" }
variable "region" { type = string; default = "us-east-1" }
variable "account_b_profile" { type = string; default = "assessment-b" }
variable "credential_key_files" {
  type = object({ engine = string, ci = string, maya = string, arun = string })
}
