#!/bin/bash
ASG=NAME_OF_THE_ASG 
SecGrp=SecurityGroup_Name
aws ec2 describe-security-groups --group-name $SecGrp | grep -i CidrIp | awk '{print $2}' | sed -e 's/"//g' > ipaddress.txt
for i in `cat ipaddress.txt`;
        do
                aws ec2 revoke-security-group-ingress --group-name $SecGrp --protocol tcp --port 443 --cidr $i;
done

id=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG \
| grep -i InstanceId | awk '{ print $2}' | cut -d "," -f1 | sed -e 's/"//g')

for j in $id
        do
                ip=$(aws ec2 describe-instances --instance-ids $j | grep -i PublicIp | awk '{print $2}' \
                | head -1 | cut -d "," -f1 | sed -e 's/"//g')
                aws ec2 authorize-security-group-ingress --group-name $SecGrp --protocol tcp --port 443 --cidr $ip/32      
done
rm ipaddress.txt
