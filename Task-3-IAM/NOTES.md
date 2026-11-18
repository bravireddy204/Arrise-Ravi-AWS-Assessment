# Task 3 - Notes

I created two groups in Account A.

Group1 has `engine` and `ci`. They are meant to use command-line access, not the AWS console.

Group2 has `maya` and `arun`. They can use the console and command line.

I created roleA for admin work except IAM. I created roleB so it can assume roleC in Account B. In Account B, roleC can access only the `ravi-111111111111-shared-files` S3 bucket.

**Would I use access keys for engine and ci in a real company?**

I would avoid permanent access keys. I would use IAM roles and temporary access instead. For a CI pipeline, I would prefer a trusted connection such as OIDC so I do not have to save a long-term AWS key.

**Why trust roleB instead of the whole Account A?**

If I trust the whole account, other users or roles in that account might also get permission to assume roleC. If I trust the exact roleB ARN, I can keep access limited to that role.
