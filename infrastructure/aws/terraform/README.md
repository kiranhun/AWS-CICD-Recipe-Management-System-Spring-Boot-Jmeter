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
Run terraform init to initialize
Run terraform plan to view/create changes
Run terraform apply to apply the changes
Run terraform destroy to destroy the network structure

**Inputs**

    1. Provide VPC name
    2. PRovide VPC cidr
    3. Provide three Subnet cidr
    4. Provide region

**Outputs**

Network structure with the above should be created in AWS
