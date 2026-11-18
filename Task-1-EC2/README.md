# Task 1 - EC2 servers

This folder has the Terraform code for five EC2 servers.

The server details are in `terraform.tfvars.example`. Before running it, I need to copy that file to `terraform.tfvars` and put in the correct AMI, subnet, security group and key pair names.

I can then run `terraform init`, `terraform plan` and `terraform apply`.

One thing to note: four servers are created using a loop. The ledger server has a separate block to protect it from deletion. So this part does not fully match the one-loop requirement yet.
