output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "azs" {
  value = data.aws_availability_zones.available.zone_ids
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "backend_ips" {
  value = join(" ", [for s in aws_instance.backend.*.private_ip : s])
}

output "backend_bucket" {
  value = module.s3_bucket.backend_bucket
}

output "backend_instance_ids" {
  value = aws_instance.backend.*.id
}

output "load_balancer_http_url" {
  value = "http://${module.load_balancer.loadbalancer_dns_name}/"
}

output "load_balancer_https_url" {
  value = "https://${module.load_balancer.loadbalancer_dns_name}/"
}

output "ssh_private_key" {
  value     = module.ssh_key.ssh_private_key
  sensitive = true
}

output "ssh_public_key" {
  value     = module.ssh_key.ssh_public_key
  sensitive = true
}

output "ssh_key_path" {
  value = module.ssh_key.ssh_key_path
}