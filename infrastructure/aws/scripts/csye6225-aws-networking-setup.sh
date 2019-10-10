#!/bin/bash
#Creation on VPCs

awsRegion=$1
vpcCidrBlock=$2
vpcName=$3
subNetCidrBlock1=$4
subNetCidrBlock2=$5
subNetCidrBlock3=$6

if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
    exit
fi

#Create vpc
vpcDetails=$(aws ec2 create-vpc --cidr-block "$vpcCidrBlock" --region "$awsRegion" --output json)
if [ $? -ne 0 ]
then
    echo "Failure: VPC creation failed"
    exit
fi

#Add tag to vpc
vpcId=$(echo -e "$vpcDetails" |  /usr/bin/jq '.Vpc.VpcId' | tr -d '"')
echo "$vpcId created...creating subnets"

aws ec2 create-tags --resources "$vpcId" --tags Key=Name,Value="$vpcName" --region "$awsRegion"

#Create subnet#1
subnetDetails1=$(aws ec2 create-subnet  --cidr-block "$subNetCidrBlock1" --region "$awsRegion" --availability-zone "${awsRegion}a"  --vpc-id "$vpcId"  --output json)
if [ $? -ne 0 ]
then
    echo "Failure: Subnet#1 creation failed"
    exit
fi
subnetId1=$(echo -e "$subnetDetails1" |  /usr/bin/jq '.Subnet.SubnetId' | tr -d '"')
echo "$subnetId1 created"

aws ec2 create-tags  --resources "$subnetId1"  --tags Key=Name,Value="firstSubnet" --region "$awsRegion"

subnetDetails2=$(aws ec2 create-subnet  --cidr-block "$subNetCidrBlock2" --region "$awsRegion" --availability-zone "${awsRegion}b"  --vpc-id "$vpcId"  --output json)
if [ $? -ne 0 ]
then
    echo "Failure: Subnet#2 creation failed"
    exit
fi
subnetId2=$(echo -e "$subnetDetails2" |  /usr/bin/jq '.Subnet.SubnetId' | tr -d '"')
echo "$subnetId2 created"

aws ec2 create-tags  --resources "$subnetId2"  --tags Key=Name,Value="secondSubnet" --region "$awsRegion"

subnetDetails3=$(aws ec2 create-subnet  --cidr-block "$subNetCidrBlock3" --region "$awsRegion" --availability-zone "${awsRegion}c"  --vpc-id "$vpcId"  --output json)
if [ $? -ne 0 ]
then
    echo "Failure: Subnet#3 creation failed"
    exit
fi
subnetId3=$(echo -e "$subnetDetails3" |  /usr/bin/jq '.Subnet.SubnetId' | tr -d '"')
echo "$subnetId3 created"

aws ec2 create-tags  --resources "$subnetId3"  --tags Key=Name,Value="thirdSubnet" --region "$awsRegion"

#Create Gateway
gatewayDetails=$(aws ec2 create-internet-gateway --region "$awsRegion" --output json)
if [ $? -ne 0 ]
then
    echo "Failure: Gateway creation failed"
    exit
fi
gatewayId=$(echo -e "$gatewayDetails" |  /usr/bin/jq '.InternetGateway.InternetGatewayId' | tr -d '"')

attach_response=$(aws ec2 attach-internet-gateway --internet-gateway-id "$gatewayId" --vpc-id "$vpcId" --region "$awsRegion")
if [ $? -ne 0 ]
then
    echo "Failure: Attaching gateway and vpc failed"
    exit
fi
routeTableDetails=$(aws ec2 create-route-table  --vpc-id "$vpcId"  --region "$awsRegion" --output json)
if [ $? -ne 0 ]
then
    echo "Failure: route table creation failed"
    exit
fi
routeTableId=$(echo -e "$routeTableDetails" |  /usr/bin/jq '.RouteTable.RouteTableId' | tr -d '"')
aws ec2 create-tags --resources "$routeTableId" --tags Key=Name,Value="$vpcName" --region "$awsRegion"

aws ec2 associate-route-table --subnet-id "$subnetId1" --route-table-id "$routeTableId" --region "$awsRegion" &> /dev/null
if [ $? -ne 0 ]
then
    echo "Failure: Route table association with  $subnetId1 failed"
    exit
else
    echo "Route table $routeTableId associated with $subnetId1"
fi
aws ec2 associate-route-table --subnet-id "$subnetId2" --route-table-id "$routeTableId" --region "$awsRegion" &> /dev/null
if [ $? -ne 0 ]
then
    echo "Failure: Route table association with $subnetId2 failed"
    exit
else
    echo "Route table $routeTableId associated with $subnetId2"
fi
aws ec2 associate-route-table --subnet-id "$subnetId3" --route-table-id "$routeTableId" --region "$awsRegion" &> /dev/null
if [ $? -ne 0 ]
then
    echo "Failure: Route table association with $subnetId3 failed"
    exit
else
    echo "Route table $routeTableId associated with $subnetId3"
fi
aws ec2 create-route --route-table-id "$routeTableId" --destination-cidr-block 0.0.0.0/0 --gateway-id "$gatewayId" --region "$awsRegion" &> /dev/null
if [ $? -ne 0 ]
then
    echo "Failure: Adding 0.0.0.0/0 cidr failed"
    exit
fi
