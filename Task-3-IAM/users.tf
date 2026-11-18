locals {
  groups = {
    group1 = ["engine", "ci"]
    group2 = ["maya", "arun"]
  }
  all_users = toset(flatten(values(local.groups)))
}

resource "aws_iam_group" "group" {
  for_each = local.groups
  name     = each.key
}

resource "aws_iam_user" "member" {
  for_each = local.all_users
  name     = each.key
}

resource "aws_iam_group_membership" "members" {
  for_each = local.groups
  name     = "${each.key}-membership"
  group    = aws_iam_group.group[each.key].name
  users    = [for name in each.value : aws_iam_user.member[name].name]
}

resource "aws_iam_access_key" "cli" {
  for_each = aws_iam_user.member
  user     = each.value.name
  pgp_key  = filebase64(var.credential_key_files[each.key])
}

# Only group2 gets console passwords.
resource "aws_iam_user_login_profile" "console" {
  for_each                = toset(local.groups.group2)
  user                    = aws_iam_user.member[each.key].name
  pgp_key                 = filebase64(var.credential_key_files[each.key])
  password_length         = 24
  password_reset_required = true
}

resource "aws_iam_group_policy" "human_access" {
  name  = "switch-roles-and-manage-own-password"
  group = aws_iam_group.group["group2"].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = [aws_iam_role.role_a.arn, aws_iam_role.role_b.arn]
      },
      {
        Effect   = "Allow"
        Action   = "iam:ChangePassword"
        Resource = "arn:aws:iam::${var.account_a_id}:user/$${aws:username}"
      },
      {
        Effect   = "Allow"
        Action   = "iam:GetAccountPasswordPolicy"
        Resource = "*"
      }
    ]
  })
}

output "initial_sign_in" {
  description = "Public access key IDs and encrypted secrets. Only the matching private key can decrypt each user's values."
  sensitive   = true
  value = {
    for name, key in aws_iam_access_key.cli : name => {
      access_key_id      = key.id
      encrypted_secret   = key.encrypted_secret
      encrypted_password = try(aws_iam_user_login_profile.console[name].encrypted_password, null)
    }
  }
}
