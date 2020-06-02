#!/bin/sh

IP=$1
TOKEN=$2

if [ -f "/home/jerry/ssd/tmp/token/token" ]; then
    echo "Remove token log file"
    rm /home/jerry/ssd/tmp/token/token
    touch /home/jerry/ssd/tmp/token/token
fi

echo "IP: $IP"
echo "Token: $TOKEN"

while [ 1 ]
do
    curl -i -k -X GET -H "X-Auth-Token: $TOKEN" "https://$IP/redfish/v1/Systems/1" >> /home/jerry/ssd/tmp/token/token 2>&1;
    sleep 10;
done;

