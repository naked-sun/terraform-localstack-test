variable "name" {
  description = "Name for the load balancer and related resources"
  type        = string
}

variable "backend_port" {
  description = "Backend instance port"
  type        = number
}

variable "vpc_id" {
  description = "VPC Id for resource placement"
  type        = string
}

variable "instance_id_list" {
  description = "Array with the backend instance id list"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of the public subnet ids."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID to be assigned to the load balancer."
  type        = string
}