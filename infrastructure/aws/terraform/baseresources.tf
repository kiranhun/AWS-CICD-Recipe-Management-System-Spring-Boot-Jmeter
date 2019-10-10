module "vpc_endpoint" {
    source = "./modules/networking"

    vpcname = ${var.vpc_name}
    subnet1 = ${var.subnetcidr1}
    subnet2 = ${var.subnetcidr2}
    subnet3 = ${var.subnetcidr3}
    vpccidr = ${var.cidr_range}
}