module "ec2" {
  source = "./modules/ec2"
  fleet  = var.fleet
}

output "instance_ids" {
  description = "EC2 instance ID by server name."
  value       = module.ec2.instance_ids
}

output "private_ips" {
  description = "Private IP address by server name."
  value       = module.ec2.private_ips
}
