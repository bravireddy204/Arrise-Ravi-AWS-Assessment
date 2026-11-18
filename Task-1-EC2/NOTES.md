# Task 1 - Notes

I used Terraform to set up five EC2 servers. I kept their settings together so they are easier to change.

| Server | Instance type | Disk type | Disk size | Key pair |
|---|---|---|---|---|
| web | t3.micro | gp3 | 20 GB | web-key |
| worker | t3.small | gp2 | 24 GB | worker-key |
| reports | m5.large | io1 | 32 GB | reports-key |
| ledger | m5.xlarge | io2 | 48 GB | ledger-key |
| sandbox | t3.medium | standard | 16 GB | sandbox-key |

I added Name, Environment and Owner tags to the servers.

I protected the ledger server because it could hold important financial data. The `prevent_destroy` setting helps stop Terraform from deleting it by mistake.

The outputs show each server's instance ID and private IP address.

There is one limitation in this version: the ledger server is in its own resource block, while the other four use a loop. I would need to change this to fully meet the question's single-resource requirement.
