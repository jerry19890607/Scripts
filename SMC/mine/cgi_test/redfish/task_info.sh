#!/bin/bash
. config

DOMAIN="https://$IP"
CGI_PATH="redfish/v1/TaskService/Tasks"
ID=$1
[ -z "$ID" ] || [ $ID -lt 0 ] || [ $ID -gt 10 ] && echo "Input Task ID" && exit 1

URL="$DOMAIN/$CGI_PATH/$ID"

curl $M_GET $URL --user $USER:$PASSWD -k 2>/dev/null | jq "."
