# Task 5 - Notes

The old code used `user/roleB` in the trust policy. But roleB is a role, not a user. Because of that, AWS was checking the wrong identity, and the real roleB could not assume roleC.

I changed it to `role/roleB`. I also made sure roleB has permission to assume roleC in Account B. Both sides need to allow the connection.

The old S3 policy used `*`, which means all resources. That was too much access. I changed it so roleC can access only the required S3 bucket and the files inside it.
