
#resource "aws_security_group_rule" "backend_http_ingress" {
#  type = "ingress"
#  from_port = 80
#  to_port = 80
#  protocol = "tcp"
#  security_group_id = aws_security_group.backend_instance.id
#  source_security_group_id = aws_security_group.frontend.id
#}

locals {
  az_count           = length(data.aws_availability_zones.available.names)
  availability_zones = data.aws_availability_zones.available.names
  load_balancer_name = "${var.stack_name}-${var.region}"
}

module "vpc" {
  source = "../modules/vpc"

  cidr               = var.vpc_cidr
  name               = var.stack_name
  availability_zones = local.availability_zones
  az_count           = local.az_count
  remote_admin_ip    = var.remote_admin_ip

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

# Generate SSH Key
module "ssh_key" {
  source = "../modules/ssh_key"
}

# S3 Module.
module "s3_bucket" {
  source = "../modules/s3"

  name   = var.stack_name
  region = var.region
}

# Compute
## Bastion Instance
resource "aws_instance" "bastion" {
  ami           = var.backend_ami_id
  instance_type = var.backend_instance_type
  key_name      = module.ssh_key.key_name

  subnet_id                   = element(module.vpc.public_subnets_ids, 0)
  vpc_security_group_ids      = [module.vpc.bastion_security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion"
  }
}

## Backend Instance(s)
resource "aws_instance" "backend" {
  count = length(module.vpc.private_subnets_ids)

  ami           = var.backend_ami_id
  instance_type = var.backend_instance_type
  key_name      = module.ssh_key.key_name

  iam_instance_profile = module.s3_bucket.backend_instance_profile_id

  subnet_id                   = element(module.vpc.private_subnets_ids, count.index)
  vpc_security_group_ids      = [module.vpc.backend_security_group_id]
  associate_public_ip_address = false

  tags = {
    Name = "Backend-${count.index}"
  }

  # Added nginx installation in the user-data to allow the instances to be registered healthy into the
  # target_group.
  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt -y install nginx
EOF
}

module "load_balancer" {
  source = "../modules/load_balancer"

  name         = local.load_balancer_name
  backend_port = var.backend_port
  vpc_id       = module.vpc.vpc_id

  instance_id_list  = aws_instance.backend.*.id
  public_subnet_ids = module.vpc.public_subnets_ids
  alb_sg_id         = module.vpc.alb_security_group_id
}