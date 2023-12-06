output "ssh_private_key" {
  value     = tls_private_key.this.private_key_openssh
  sensitive = true
}

output "ssh_public_key" {
  value     = tls_private_key.this.public_key_openssh
  sensitive = true
}

output "key_name" {
  value = aws_key_pair.this.key_name
}

output "ssh_key_path" {
  value = local_sensitive_file.pem_file.filename
}