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

variable "my_fe_inbound_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    {port  = 22, cidr = "0.0.0.0/0"},
    {port = 80, cidr = "0.0.0.0/0"},
  ]
}

variable "my_api_inbound_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    {port  = 22, cidr = "0.0.0.0/0"},
    {port = 8080, cidr = "0.0.0.0/0"},
  ]
}

variable "my_db_inbound_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
    {port  = 22, cidr = "0.0.0.0/0"},
    {port = 5432, cidr = "0.0.0.0/0"},
  ]
}

variable "frontend" {
  type = object({
    instance_type   = string
    subnet          = string
    ami             = string
    security_groups = list(string)
  })
  default = {
    instance_type   = "t2.micro"
    subnet          = "frontend"
    ami             = "ami-frontend-id"
    security_groups = [aws_security_group.my-fe-sg.id] # List of SG IDs
  }
  description = "Configuration for the frontend EC2 instance."
}

variable "api" {
  type = object({
    instance_type   = string
    subnet          = string
    ami             = string
    security_groups = list(string)
  })
  default = {
    instance_type   = "t2.micro"
    subnet          = "backend" # Assuming backend subnet for API
    ami             = "ami-api-id"
    security_groups = [aws_security_group.my-api-sg.id] # List of SG IDs
  }
  description = "Configuration for the API EC2 instance."
}

variable "db" {
  type = object({
    instance_type   = string
    subnet          = string
    ami             = string
    security_groups = list(string)
  })
  default = {
    instance_type   = "t2.micro"
    subnet          = "database"
    ami             = "ami-db-id"
    security_groups = [aws_security_group.my-db-sg.id]
  }
  description = "Configuration for the database EC2 instance."
}


variable "db_configs_map"{
  description = "Map of database configurations ."
  type = map(object({
    allocated_storage = number
    db_name = string
    engine = string
    engine_version = string
    instance_class = string
    username = string
    password = string
    parameter_group_name = string
    skip_final_snapshot = bool
  }))

}

