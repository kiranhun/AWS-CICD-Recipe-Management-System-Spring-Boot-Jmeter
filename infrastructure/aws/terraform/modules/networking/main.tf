resource "aws_vpc" "vpc" {
    cidr_block  =   var.vpccidr
    instance_tenancy = var.default_tenancy
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support

    tags = {
        "Name" = var.vpcname
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        "Name" = "Internet Gateway"
    }
}

resource "aws_route_table" "vpcroute_table" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        "Name" = "Route Table"
    }
}

resource "aws_route" "internet_access" {
    route_table_id = aws_route_table.vpcroute_table.id
    destination_cidr_block = var.destinationCIDRblock
    gateway_id = aws_internet_gateway.internet_gateway.id
}

data "aws_availability_zones" "available" {
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.subnet1
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        "Name" = "Subnet One"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.subnet2
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        "Name" = "Subnet Two"
    }
}

resource "aws_subnet" "subnet3" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.subnet3
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[2]

    tags = {
        "Name" = "Subnet Three"
    }
    
}

resource "aws_route_table_association" "association_one" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.vpcroute_table.id
}

resource "aws_route_table_association" "association_two" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.vpcroute_table.id
}

resource "aws_route_table_association" "association_three" {
    subnet_id = aws_subnet.subnet3.id
    route_table_id = aws_route_table.vpcroute_table.id
}