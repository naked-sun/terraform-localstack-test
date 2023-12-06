variable "region" {
  description = "Region defined for the stack."
  type        = string
}

variable "vpc_cidr" {
  description = "Network block (CIDR) for VPC."
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of the CIDRs for public subnets"
  type        = list(string)
  default     = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of the CIDRs for private subnets"
  type        = list(string)
  default     = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "List of the CIDRs for database subnets"
  type        = list(string)
  default     = ["192.168.20.0/24", "192.168.21.0/24", "192.168.22.0/24"]
}

#variable "network_prefix" {
#  description = "Prefix for the network CIDR, unamovable part of the CIDR to facilitate concatenation on subnet division."
#  type        = string
#}

variable "stack_name" {
  description = "Name for the terraform stack."
  type        = string
}

variable "availability_zones" {
  description = "Array for Availability Zones"
  type        = list(string)
}

variable "backend_ami_id" {
  description = "AWS AMI Id form Backend hosts."
  type        = string
}

variable "backend_instance_type" {
  description = "EC2 Instance type."
  default     = "t2.micro"
  type        = string
}

variable "remote_admin_ip" {
  description = "Source IP Address that can SSH into the backend EC2 instances."
  type        = string
}

variable "backend_port" {
  description = "TCP port number for backend and target group."
  type        = number
  default     = 80
}