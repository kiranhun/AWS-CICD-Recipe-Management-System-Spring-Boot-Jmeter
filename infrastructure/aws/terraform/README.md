**AWS VPC Terraform module**

Terraform module which creates network structure consiting of
    1. Virtual Private Cloud
    2. Subnet across three availability zones
    3. Internet Gateway
    4. Public route table
    5. Access to internet provided

**How to Run the module**

Install Terraform from https://www.terraform.io/downloads.html
Install AWS CLI from https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
Configure AWS CLI from https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

**Terraform Commands**

Open terrform folder in terminal
Run `terraform init` to initialize
Run `terraform plan` to view/create changes
Run `terraform apply` to apply the changes
Run `terraform destroy` to destroy the network structure

**Inputs**

     1. Provide VPC name
        2. PRovide VPC cidr
        3. Provide three Subnet cidr
        4. Provide region
        5. AMI inage id
        6. S3 bucket name
    
    We can give all inputs in one form - 
    
    `terraform plan -out=test -var aws_profile={profile} -var vpc_name={vpcname} -var cidr_range={vpc cidr} -var subnetcidr1={subnet cidr} -var subnetcidr2={subnet cidr} -var subnetcidr3={subnet cidr} -var region={region} -var image_id={image_ID} -var bucket_name={s3_bucketname}`
    
    To apply changes - `terraform apply test`

We can give all inputs in one form - 

`terraform plan -out=test -var aws_profile={profile} -var vpc_name={vpcname} -var cidr_range={vpc cidr} -var subnetcidr1={subnet cidr} -var subnetcidr2={subnet cidr} -var subnetcidr3={subnet cidr} -var region={region}`

To apply changes - `terraform apply test`

**Workspaces**

If multiple VPC's need to be launched, terraform workspaces should be used:

`terraform workspace new workspace-2`
From here on initialize the module and run the commands to plan & apply
If you need to switch back to default workspace, you can do `terraform workspace select default`

**Outputs**

Network structure with the above should be created in AWS
