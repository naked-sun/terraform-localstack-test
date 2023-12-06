# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = var.name
  }
}

# Subnets
## Frontend Subnets
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "Frontend"
  }
}

## Backend Subnets
resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "Backend"
  }
}

## Database Subnets
resource "aws_subnet" "database" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.database_subnet_cidrs, count.index)
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "Database"
  }
}

# Internet Access
## Internet Gateway for public Subnets.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Blackhole
## Created a network interface not attached to anything to emulate a blackhole for the default route in the
## database subnet.
resource "aws_network_interface" "blackhole" {
  subnet_id       = element(aws_subnet.database.*.id, 0)
  security_groups = [data.aws_security_group.default.id]

  tags = {
    Name = "${var.name}-Blackhole"
  }
}

# Nat Gateway
## NGW requires public ip to access internet.
resource "aws_eip" "nat_gw" {}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.public[0].id
}

# Route Table
## Frontend
resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-public"
  }

  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_subnet.id
}

## Backend
resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private"
  }

  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "backend" {
  count = var.az_count

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_subnet.id
}

## Database
# Fix here the routes with some local calculated vars.
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-database"
  }

  # Having more time I would add here only routes to the backend subnets and the database subnets.
  route {
    cidr_block = var.cidr
    gateway_id = "local"
  }

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.blackhole.id
  }
}

# Security Groups
## Bastion
resource "aws_security_group" "bastion" {
  name        = "Bastion"
  description = "Security Group for Bastion access"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  cidr_blocks       = [var.remote_admin_ip]
}

resource "aws_security_group_rule" "bastion_ingress_local_network" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.bastion.id
  self              = true
}

resource "aws_security_group_rule" "bastion_egress_local_network" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_egress_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = [var.cidr]
}

## Load Balancer
resource "aws_security_group" "alb" {
  name        = "Load Balancer"
  description = "Load balancer security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "public_http_ingress" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_backend_egress" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  cidr_blocks       = [var.cidr]
}

resource "aws_security_group_rule" "public_https_ingress" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

## Backend
resource "aws_security_group" "backend_instance" {
  name        = "Backend"
  description = "Manage SG rules to compute instances in backend subnet(s)."
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "alb_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend_instance.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "backend_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.backend_instance.id
}

resource "aws_security_group_rule" "backend_ingress_local_network" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.backend_instance.id
  self              = true
}

resource "aws_security_group_rule" "backend_egress_local_network" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.backend_instance.id
  cidr_blocks       = ["0.0.0.0/0"]
}