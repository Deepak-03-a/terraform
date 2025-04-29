resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
  tags = {
    name = var.vpc_name
    instance_tenancy = var.vpc_tenancy
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  for_each = var.public_subnet_cidrs
  cidr_block = each.value
  map_public_ip_on_launch = "True"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  for_each = var. private_subnet_cidrs
  cidr_block = each.value
  map_public_ip_on_launch = "False"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

resource "aws_eip" "nat_eip" {
  for_each = var.private_subnet_cidrs
  domain = "vpc"
  tags = {
    Name = "nat-eip-${each.key}"
  }
}


resource "aws_nat_gateway" "my-nat" {
  for_each = var.private_subnet_cidrs
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id = aws_subnet.private_subnet[each.key].id

}
