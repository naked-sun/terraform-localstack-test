resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "deployer-key"
  public_key = tls_private_key.this.public_key_openssh
}

# Store the private key in the home ssh directory to access the EC2 instances.
resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("~/.ssh/id_rsa_terraform_testapp.pem")
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.this.private_key_pem
}