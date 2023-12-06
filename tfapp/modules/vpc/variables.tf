variable "cidr" {
  description = "Network CIDR used for the VPC."
  type        = string
}

variable "name" {
  description = "Stack Name"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones where the services should be distributed to."
  type        = list(string)
}

variable "az_count" {
  description = "Number of availability zones to be used."
  type        = number
}

#variable "network_prefix" {
#  type = string
#}

variable "remote_admin_ip" {
  description = "Source IP Address that can SSH into the backend EC2 instances."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of the CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of the CIDRs for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "List of the CIDRs for database subnets"
  type        = list(string)
}
