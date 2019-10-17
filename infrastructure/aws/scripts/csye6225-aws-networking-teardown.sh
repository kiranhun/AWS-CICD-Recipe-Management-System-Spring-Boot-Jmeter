#!/bin/bash
#Teardown on VPCs


vpcId=$1
awsRegion=$2

if [ "$vpcId" = "" ]
then
   echo "Please provide the vpc id"
   exit
fi

if [ "$awsRegion" = "" ]
then
   echo "Please provide the region"
   exit
fi

#Get the subnet details

subNetDetails=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values="$vpcId"" --region "$awsRegion" --output json)
if [ "$subNetDetails" = "None" ]
then
    echo "No Subnets exists for vpc: $vpcId"
    exit
fi
subnet1=$(echo -e "$subNetDetails" | /usr/bin/jq '.Subnets[0].SubnetId' | tr -d '"')
subnet2=$(echo -e "$subNetDetails" | /usr/bin/jq '.Subnets[1].SubnetId' | tr -d '"')
subnet3=$(echo -e "$subNetDetails" | /usr/bin/jq '.Subnets[2].SubnetId' | tr -d '"')

#Get the vpc details

vpcDetails=$(aws ec2 describe-vpcs --vpc-ids "$vpcId" --region "$awsRegion" --output json)
vpcName=$(echo -e $vpcDetails | /usr/bin/jq '.Vpcs[0].Tags[0].Value' | tr -d '"')
echo $vpcName

#delete subnets

aws ec2 delete-subnet --subnet-id "$subnet1" --region "$awsRegion"
if [ $? -eq 0 ]
then
    echo "Successfully deleted Subnet: $subnet1"
else
    echo "Failure: coudn't delete Subnet: $subnet1"
fi
aws ec2 delete-subnet --subnet-id "$subnet2" --region "$awsRegion"
if [ $? -eq 0 ]
then
    echo "Successfully deleted Subnet: $subnet2"
else
    echo "Failure: coudn't delete Subnet: $subnet2"
fi
aws ec2 delete-subnet --subnet-id "$subnet3" --region "$awsRegion"
if [ $? -eq 0 ]
then
    echo "Successfully deleted Subnet: $subnet3"
else
    echo "Failure: coudn't delete Subnet: $subnet3"
fi

#Get Internet Gateway details

internetGatewayDetails=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values="$vpcId"" --region "$awsRegion" --output json)
if [ "$internetGatewayDetails" = "None" ]
then
    echo "No internet gateway exists for vpc: $vpcId"
fi
internetGatewayId=$(echo -e "$internetGatewayDetails" | /usr/bin/jq '.InternetGateways[0].InternetGatewayId' | tr -d '"')


#Detach internet gateway and vpc

aws ec2 detach-internet-gateway --internet-gateway-id "$internetGatewayId" --vpc-id "$vpcId" --region "$awsRegion" 
if [ $? -ne 0 ]
then
    echo "Could not dettach $internetGatewayId from $vpcId"
fi

#Detele Internet Gateway

aws ec2 delete-internet-gateway --internet-gateway-id "$internetGatewayId" --region "$awsRegion"
if [ $? -ne 0 ]
then
    echo "Could not delete $internetGatewayId"
fi

#Get Route Table details

routeTableDetails=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values="$vpcName"" --region "$awsRegion" --output json)
routeTableId=$(echo -e "$routeTableDetails" | /usr/bin/jq '.RouteTables[0].RouteTableId' | tr -d '"')

#Delete 0.0.0.0/0 in Route Table

aws ec2 delete-route --route-table-id "$routeTableId" --destination-cidr-block 0.0.0.0/0 --region "$awsRegion"
if [ $? -ne 0 ]
then
    echo "Could not delete route 0.0.0.0/0 in  $routeTableId"
fi

# Delete route table

aws ec2 delete-route-table --route-table-id  $routeTableId --region "$awsRegion"
if [ $? -ne 0 ]
then
    echo "Could not delete route table $routeTableId"
fi

# Delete VPC

aws ec2 delete-vpc --vpc-id "$vpcId" --region "$awsRegion"
if [ $? -ne 0 ]
then
    echo "Could not delete vpc: "$vpcId""
else
    echo "vpc $vpcId deleted"
fi
