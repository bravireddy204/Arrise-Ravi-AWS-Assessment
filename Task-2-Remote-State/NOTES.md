# Task 2 - Notes

Terraform state is a file that keeps track of what Terraform has created.

If two people use separate local state files, they may both try to make changes without knowing what the other person has done. This can cause problems.

I used S3 so the team can keep the state file in one place. I used DynamoDB locking so two people do not change that shared state at the same time. One person can run the change, and the other has to wait or try again.

I used DynamoDB because the task asks for it. For a new project, I would also check the newer S3 locking option.
