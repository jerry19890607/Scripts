#!/bin/bash
. config

DOMAIN="https://$IP"
CGI_PATH="redfish/v1/Systems/1/Actions/ComputerSystem.Reset"

CMD=$1
case $CMD in
    "ForceOff")
        ;;
    "ForceOn")
        ;;
    *)
        echo "ForceOff, ForceOn"
        exit 1
        ;;
esac

URL="$DOMAIN/$CGI_PATH"
QSTR_1="-d {\"ResetType\":\"$CMD\"}"

curl $M_POST $URL --user $USER:$PASSWD $QSTR_1 -k 2>/dev/null | jq "."
