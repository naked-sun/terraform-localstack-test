data "aws_security_group" "default" {
  vpc_id = aws_vpc.main.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}