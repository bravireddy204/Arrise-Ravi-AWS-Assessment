locals {
  tags = {
    Environment = var.fleet.environment
    Owner       = var.fleet.owner
  }
  ledger = var.fleet.instances["ledger"]
  others = { for name, spec in var.fleet.instances : name => spec if name != "ledger" }
}

resource "aws_instance" "other" {
  for_each = local.others

  ami                         = var.fleet.ami_id
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  subnet_id                   = var.fleet.subnet_id
  vpc_security_group_ids      = var.fleet.security_group_ids
  associate_public_ip_address = false

  root_block_device {
    volume_type = each.value.root_type
    volume_size = each.value.root_gib
    iops        = each.value.iops
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(local.tags, { Name = each.key })
}

# Terraform requires a literal value for prevent_destroy, so ledger has its own block.
resource "aws_instance" "ledger" {
  ami                         = var.fleet.ami_id
  instance_type               = local.ledger.instance_type
  key_name                    = local.ledger.key_name
  subnet_id                   = var.fleet.subnet_id
  vpc_security_group_ids      = var.fleet.security_group_ids
  associate_public_ip_address = false

  root_block_device {
    volume_type = local.ledger.root_type
    volume_size = local.ledger.root_gib
    iops        = local.ledger.iops
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(local.tags, { Name = "ledger" })

  lifecycle {
    prevent_destroy = true
  }
}
