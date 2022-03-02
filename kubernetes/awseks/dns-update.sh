#!/bin/sh

zoneid=$1
elbzoneid=$2
subdomain=$3
ELB=$4
# UPSERT DELETE CREATE
action=$5  

# Creates route 53 records based on env name

aws route53 change-resource-record-sets \
  --hosted-zone-id $zoneid \
  --change-batch '
  {
     "Comment": "Creating Alias resource record sets in Route 53",
     "Changes": [{
                "Action": "'"$action"'",
                "ResourceRecordSet": {
                            "Name": "'"$subdomain"'",
                            "Type": "A",
                            "AliasTarget":{
                                    "HostedZoneId": "'"$elbzoneid"'",
                                    "DNSName": "'"$ELB"'",
                                    "EvaluateTargetHealth": false
                              }}
                          }]
}
  '
