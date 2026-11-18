# Task 5 - Fix the bug

This folder has the corrected Terraform example in `fixed-roleC.tf`.

The main fix is changing the trust policy from a user ARN to the correct role ARN. I also limited the S3 permissions to the required bucket.

This is an example of the fix. It still needs the Account A role setup from Task 3.
