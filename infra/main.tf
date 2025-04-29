resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
  tags = {
    name = var.vpc_name
  }
}