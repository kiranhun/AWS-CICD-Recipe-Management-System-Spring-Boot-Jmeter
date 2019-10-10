#Setup AWS CLI

1) Install AWS Command Line Interface
2) Configure the config and credential files by running aws configure command for dev and prod
3) Create shell script csye6225-aws-networking-setup.sh to setup network configuration using AWS CLI
4) Create shell script csye6225-aws-networking-teardown.sh to delete networking resources using AWS CLI

#Infrastructure creation using AWS CLI

1) Create a Virtual Private Cloud(VPC)
2) Create subnets in your VPC. You must create 3 subnets, each in different availability zone in the same region in the same VPC.
3) Create Internet Gateway resource. and attach the Internet Gateway to the VPC.
4) Create a public route table. Attach all subnets created above to the route table.
5) Create a public route in the public route table created above with destination CIDR block 0.0.0.0/0 and internet gateway created above as the target.

#Create Infrastructure using csye6225-aws-networking-setup.sh
1) export AWS_PROFILE=dev or prod
2) run csye6225-aws-networking-setup.sh as below:
   ./csye6225-aws-networking-setup.sh region cidr_vpc vpc_name cidr_subnet#1 cidr_subnet#2 cidr_subnet#3
   ./csye6225-aws-networking-setup.sh us-east-2 10.0.0.0/16 TestingVpc 10.0.1.0/24 10.0.2.0/24 10.0.3.0/24	

#Deleting the Infrastructure using csye6225-aws-networking-teardown.sh
1) export AWS_PROFILE=dev or prod
2) run csye6225-aws-networking-teardown.sh as below:
   ./csye6225-aws-networking-teardown.sh vpc_id region 
   ./csye6225-aws-networking-teardown.sh vpc-004a72ca158ed4af9 us-east-2
