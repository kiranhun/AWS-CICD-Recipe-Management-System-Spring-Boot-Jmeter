module "networking" {
    source = "./modules/networking"

    vpcname = var.vpc_name
    subnet1 = var.subnetcidr1
    subnet2 = var.subnetcidr2
    subnet3 = var.subnetcidr3
    vpccidr = var.cidr_range
    region = var.region
}

module "ec2_host" {
    source = "./modules/application"

    subnet_id = module.networking.subnet_id1
    security_group = aws_security_group.webapp.id
    image_id = var.image_id
    key_pair = var.key_pair
}
