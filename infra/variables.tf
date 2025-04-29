variable access_key {
  description = "Please Enter the valid access key to perform the action"
}

variable Secret_access_key {
  description = "Please Enter a valid secret access key to perform the action"
}

variable cidr {
  description = "Please enter a valid cidr_black for your VPC. "
}

variable vpc_tenancy {
  default = "default"
}

variable vpc_name {
  description = "Please enter a name for your VPC. "
}

variable public_subnet_cidrs {
  description = "Please Input subnet details"
  type = map(string)
  default = {
   forntend = "10.0.0.0/24"
   backend = "10.0.1.0/24"
   loadbalancer = "10.0.2.0/24"
  }
}

variable private_subnet_cidrs {
  description = "Please Input subnet details"
  type = map(string)
  default = {
   database = "10.0.3.0/24"
   cache = "10.0.4.0/24"
  }
}

