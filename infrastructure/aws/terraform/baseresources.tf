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
    source              = "./modules/application"
    subnet_id           = module.networking.subnet_id1
    subnet_id2          = module.networking.subnet_id2
    subnet_id3          = module.networking.subnet_id3
    #subnet_ids         = [module.networking.subnet_id2, module.networking.subnet_id3]
    security_group      = aws_security_group.webapp.id
    security_group_list = [aws_security_group.database.id]
    image_id            = var.image_id
    key_pair            = var.key_pair
}
