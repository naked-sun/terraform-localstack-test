output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR."
  value       = aws_vpc.main.cidr_block
}

output "public_subnets_ids" {
  description = "List of public subnets."
  value       = aws_subnet.public.*.id
}

output "private_subnets_ids" {
  description = "List of private subnets."
  value       = aws_subnet.private.*.id
}
output "bastion_security_group_id" {
  description = "Security Group ID for Bastion instance."
  value       = aws_security_group.bastion.id
}

output "backend_security_group_id" {
  description = "Security Group ID for backend instance(s)."
  value       = aws_security_group.backend_instance.id
}

output "alb_security_group_id" {
  description = "Security Group ID for load balancer."
  value       = aws_security_group.alb.id
}
