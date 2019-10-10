#!/bin/bash
#Teardown on VPCs


vpcId=$1
awsRegion=$2

subNetDetails=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values="$vpcId"" --region "$awsRegion" --output json)

subnet1=$(echo -e "$subNetDetails" | /usr/bin/jq '.Subnets[0].SubnetId' | tr -d '"')
subnet2=$(echo -e "$subNetDetails" | /usr/bin/jq '.Subnets[1].SubnetId' | tr -d '"')
subnet3=$(echo -e "$subNetDetails" | /usr/bin/jq '.Subnets[2].SubnetId' | tr -d '"')

vpcDetails=$(aws ec2 describe-vpcs --vpc-ids "$vpcId" --region "$awsRegion" --output json)
vpcName=$(echo -e $vpc | /usr/bin/jq '.Vpcs[0].Tags[0].Value' | tr -d '"')
aws ec2 delete-subnet --subnet-id "$subnet1" --region "$awsRegion"
aws ec2 delete-subnet --subnet-id "$subnet2" --region "$awsRegion"
aws ec2 delete-subnet --subnet-id "$subnet3" --region "$awsRegion"

internetGatewayDetails=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values="$vpcId"" --region "$awsRegion" --output json)
internetGatewayId=$(echo -e "$internetGatewayDetails" | /usr/bin/jq '.InternetGateways[0].InternetGatewayId' | tr -d '"')

aws ec2 detach-internet-gateway --internet-gateway-id "$internetGatewayId" --vpc-id "$vpcId" --region "$awsRegion" 
aws ec2 delete-internet-gateway --internet-gateway-id "$internetGatewayId" --region "$awsRegion"

#routeTableDetails=$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values="$vpcId"" --region "$awsRegion" --output json)
routeTableDetails=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=TestingVpc" --region us-east-2 --output json)
routeTableId=$(echo -e "$routeTableDetails" | /usr/bin/jq '.RouteTables[0].RouteTableId' | tr -d '"')
echo $routeTableId
aws ec2 delete-route --route-table-id "$routeTableId" --destination-cidr-block 0.0.0.0/0 --region "$awsRegion"

#routeTableDetails=$(aws ec2 describe-route-tables --filters "Name=route-table-id,Values=routeTableId" --region us-east-2 --output json)
#routeTableDestCIDR=$(echo -e $routeTableDetails | /usr/bin/jq '.RouteTables[0].Routes[0].DestinationCidrBlock' | tr -d '"')
echo $routeTableDestCIDR
#aws ec2 delete-route --route-table-id "$routeTableId" --destination-cidr-block "$routeTableDestCIDR" --region "$awsRegion"
aws ec2 delete-route-table --route-table-id  $routeTableId --region "$awsRegion"


aws ec2 delete-vpc --vpc-id "$vpcId" --region "$awsRegion"
