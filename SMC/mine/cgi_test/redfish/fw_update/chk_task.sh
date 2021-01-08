#!/bin/bash
. config

[ -z "$IP" ] && echo "IP not found, check config file" && exit 1

DOMAIN="https://$IP"
CGI_PATH="redfish/v1/TaskService"

URL="$DOMAIN/$CGI_PATH"

ret=`curl $M_GET $URL --user $USER:$PASSWD -k 2>/dev/null | jq ".ServiceEnabled"`

case $ret in
    "false")
        echo "To Enable Task..."
        QSTR_1="{\"ServiceEnabled\": true}"
        curl $M_PATCH $URL --user $USER:$PASSWD -d "$QSTR_1" -k 2>/dev/null | jq "."
        ;;
esac
