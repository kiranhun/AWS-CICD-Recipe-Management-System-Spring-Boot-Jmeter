**VPC using CloudFormation Task**


1. Create Virtual Private Cloud (VPC).
2. Create subnets in your VPC. You must create 3 subnets, each in different availability zone in the same region in the same VPC.
3. Create Internet Gateway resource. and attach the Internet Gateway to the VPC.
4. Create a public route table. Attach all subnets created above to the route table.
5. Create a public route in the public route table created above with destination CIDR block 0.0.0.0/0 and internet gateway created above as the target.


**AWS CLI SETUP**
1. Install AWS Command Line Interface.
2. Run aws configure command and enter all the credentials for the root user.
3. Enter dev and prod user credentials and configuration in config and credentials file 


**Steps to Create a Stack** :
1. Execute command "export AWS_PROFILE=prod".
2. Run bash csye6225-aws-cf-create-stack.sh <stackname> <vpcName> <awsRegion> <vpcCidrBlock> <Subnet1CidrBlock> <Subnet2CidrBlock> <Subnet3Block>. eg. (sh csye6225-aws-cf-create-stack.sh newStack newVPC us-east-1 10.0.0.0/16 10.0.0.0/18 10.0.64.0/18 10.0.128.0/17)

**Steps to Delete a Stack**
1. bash csye6225-aws-cf-terminate-stack.sh <stackName> <awsRegion>. eg ( bash csye6225-aws-cf-terminate-stack.sh newstack us-east-1)

