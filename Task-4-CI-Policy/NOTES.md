# Task 4 - Notes

I gave the CI user only the permissions needed for deployment.

It can push Docker images to the `ravi-app` ECR repository. It can register a task definition and update the `web` ECS service in the `assessment` cluster. It can also list and download files from the build-artifacts S3 bucket.

I did not allow CI to delete images, create other repositories, change other ECS services or upload and delete build files. These are not needed for this deployment.

One thing to remember is that ECS uses the same update action for a few service settings, so that permission needs careful handling in a real project.
