# Task 4 - CI policy

This folder has the custom IAM policy for the CI user.

It lets CI upload a Docker image to one ECR repository, deploy an update to one ECS service and read files from one S3 bucket.

The JSON file is the policy. The template file can be used when account or region values need to be filled in.

The CI user is created in Task 3, so the policy needs to be attached to that user.
