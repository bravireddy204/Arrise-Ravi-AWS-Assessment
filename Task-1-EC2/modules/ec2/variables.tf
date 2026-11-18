terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.38.0"
    }
  }
}

variable "fleet" {
  description = "Shared network, image and tags, plus one entry for each server."
  type = object({
    ami_id             = string
    subnet_id          = string
    security_group_ids = set(string)
    environment        = string
    owner              = string
    instances = map(object({
      instance_type = string
      root_type     = string
      root_gib      = number
      key_name      = string
      iops          = optional(number)
    }))
  })
  nullable = false

  validation {
    condition     = length(var.fleet.instances) == 5 && contains(keys(var.fleet.instances), "ledger")
    error_message = "Supply exactly five named servers, including the protected server called ledger."
  }

  validation {
    condition = alltrue([
      length(distinct(values(var.fleet.instances)[*].instance_type)) == 5,
      length(distinct(values(var.fleet.instances)[*].root_type)) == 5,
      length(distinct(values(var.fleet.instances)[*].root_gib)) == 5,
      length(distinct(values(var.fleet.instances)[*].key_name)) == 5
    ])
    error_message = "Give each server a different instance type, boot disk type, boot disk size and EC2 key pair."
  }

  validation {
    condition = alltrue([for s in values(var.fleet.instances) :
      contains(["gp3", "gp2", "io1", "io2", "standard"], s.root_type) &&
      s.root_gib > 0 && s.root_gib == floor(s.root_gib)
    ])
    error_message = "Choose a supported boot disk type and use a positive whole number of GiB."
  }

  validation {
    condition = alltrue([for s in values(var.fleet.instances) :
      contains(["io1", "io2"], s.root_type)
      ? try(s.iops >= 100 && s.iops == floor(s.iops), false)
      : s.iops == null
    ])
    error_message = "Specify whole-number IOPS of at least 100 for io1 and io2. The other sample disk types use their defaults."
  }

  validation {
    condition = (
      length(var.fleet.security_group_ids) > 0 &&
      trimspace(var.fleet.environment) != "" && trimspace(var.fleet.owner) != ""
    )
    error_message = "Provide a security group, an environment and an owner."
  }
}
