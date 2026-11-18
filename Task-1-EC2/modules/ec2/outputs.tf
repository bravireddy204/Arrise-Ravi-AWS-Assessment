locals {
  by_name = merge(aws_instance.other, { ledger = aws_instance.ledger })
}

output "instance_ids" {
  value = { for name, server in local.by_name : name => server.id }
}

output "private_ips" {
  value = { for name, server in local.by_name : name => server.private_ip }
}
