# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
  tags = {
    name = var.vpc_name
    instance_tenancy = var.vpc_tenancy
  }
}

# public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  for_each = var.public_subnet_cidrs
  cidr_block = each.value
  map_public_ip_on_launch = "True"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  for_each = var. private_subnet_cidrs
  cidr_block = each.value
  map_public_ip_on_launch = "False"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# Elastic Ip
resource "aws_eip" "nat_eip" {
  for_each = var.private_subnet_cidrs
  domain = "vpc"
  tags = {
    Name = "nat-eip-${each.key}"
  }
}

# NAT gateway
resource "aws_nat_gateway" "my-nat" {
  for_each = var.private_subnet_cidrs
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id = aws_subnet.private_subnet[each.key].id
}

# Public route table
resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# private route table
resource "aws_route_table" "my_private_rt"{
  for_each = var.private_subnet_cidrs
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat[each.key].id
  }
  tags = {
    Name = "${var.vpc_name}-${each.key}-private -rt"
  }
}

# Public route table - public subnet association
resource "aws_route_table_association" "my-public-asc" {
  for_each = var.private_subnet_cidrs
  subnet_id = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.my_public_rt.id
}

# Private route table - private subnet association
resource "aws_route_table_association" "my-private-asc" {
  for_each = var.private_subnet_cidrs
  subnet_id = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.my_private_rt[each.key].id
}

# Public NACL
resource "aws_network_acl" "my-public-nacl" {
  vpc_id = aws_vpc.my_vpc.id
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 65535
  }

  tags = {
    Name = "${var.vpc_name}-public-nacl"
  }

}

# Public nacl Association
resource "aws_network_acl_association" "my-public-nacl-asc" {
  for_each = var.public_subnet_cidrs
  network_acl_id = aws_network_acl.my-public-nacl.id
  subnet_id      = aws_subnet.public_subnet[each.key].id
}

# Private NACL
resource "aws_network_acl" "my-private-nacl" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 65535
  }

  tags = {
    Name = "${var.vpc_name}-private-nacl"
  }
}

# private nacl association
resource "aws_network_acl_association" "my-private-nacl-asc" {
  for_each = var.public_subnet_cidrs
  network_acl_id = aws_network_acl.my-private-nacl.id
  subnet_id      = aws_subnet.private_subnet[each.key].id
}

#frontend security group
resource "aws_security_group" "my-fe-sg" {
  name = "my-frontend"
  description = "Allow frontend Traffic"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-fe-sg"
  }
}

# frontend security group rules
resource "aws_vpc_security_group_ingress_rule" "my-fe-sg-rules" {
  security_group_id = aws_security_group.my-fe-sg.id
  count = length(var.my_fe_inbound_ports)
  cidr_ipv4 = var.my_fe_inbound_ports[count.index].cidr
  from_port = var.my_fe_inbound_ports[count.index].port
  ip_protocol       = "tcp"
  to_port = var.my_fe_inbound_ports[count.index].port
}

# API security group
resource "aws_security_group" "my-api-sg" {
  name = "my-api"
  description = "Allow Api Traffic"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-api-sg"
  }
}
# Api security group rules
resource "aws_vpc_security_group_ingress_rule" "my-api-sg-rules" {
  security_group_id = aws_security_group.my-api-sg.id
  count = length(var.my_api_inbound_ports)
  cidr_ipv4 = var.my_api_inbound_ports[count.index].cidr
  from_port = var.my_api_inbound_ports[count.index].port
  ip_protocol       = "tcp"
  to_port = var.my_api_inbound_ports[count.index].port
}

# DB security group
resource "aws_security_group" "my-db-sg" {
  name = "my-db "
  description = "Allowing DB Traffic"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

# DB security group names
resource "aws_vpc_security_group_ingress_rule" "my-db-sg-rules" {
  security_group_id = aws_security_group.my-db-sg.id
  count =length(var.my_db_inbound_ports)
  cidr_ipv4 = var.my_db_inbound_ports[count.index].cidr
  from_port = var.my_db_inbound_ports[count.index].port
  ip_protocol       = "tcp"
  to_port = var.my_db_inbound_ports[count.index].port

}

# Local for easier access of egress rules
locals {
  security_groups ={
    fe = aws_security_group.my-fe-sg.id
    api = aws_security_group.my-api-sg.id
    db = aws_security_group.my-db-sg.id
  }
}

#Common Egress Rules - Outbound All
resource "aws_vpc_security_group_egress_rule" "my-common-outbound" {
  for_each = local.security_groups
  security_group_id = each.value
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 0
  ip_protocol       = "tcp"
  to_port = 65535

}
# Creating frontend instances
resource "aws_instance" "my_frontend_instance" {
  ami = var.frontend.ami
  instance_type = var.frontend.instance_type
  subnet_id = aws_subnet.public_subnet[var.frontend.subnet].id
  security_groups = var.frontend.security_groups

  tags = {
    Name = "${var.vpc_name}-frontend-instance"
  }
}
# Creating api instances
resource "aws_instance" "my_api_instance" {
  ami = var.api.ami
  instance_type = var.api.instance_type
  subnet_id = aws_subnet.public_subnet[var.api.subnet].id
  security_groups = var.api.security_groups

  tags = {
    Name = "${var.vpc_name}-api-instance"
  }
}
# Creating DB instances
resource "aws_instance" "my_db_instance" {
  ami = var.db.ami
  instance_type = var.db.instance_type
  subnet_id = aws_subnet.public_subnet[var.db.subnet].id
  security_groups = var.db.security_groups

  tags = {
    Name = "${var.vpc_name}-api-instance"
  }
}

# Creating RDS
resource "aws_db_instance" "my-db" {
  for_each = var.db_configs_map
  allocated_storage = each.value.allocated_storage
  db_name = each.value.db_name
  engine = each.value.engine
  engine_version = each.value.engine_version
  instance_class = each.value.instance_class
  username = each.value.username
  password = each.value.password
  parameter_group_name = each.value.parameter_group_name
  skip_final_snapshot = each.value.skip_final_snapshot

  tags = {
    Name = "db-${each.key}"
  }
}
