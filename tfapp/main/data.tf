data "aws_availability_zones" "available" {
  filter {
    name   = "zone-name"
    values = var.availability_zones
  }
}

# The filter is commented to be used as variable directly, because this filter doesn't work with localstack
#data "aws_ami" "backend" {
#  filter {
#    name = "image-id"
#    values = [var.backend_ami_id]
#  }
#}
