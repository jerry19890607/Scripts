#!/bin/bash
. config

[ -z "$IP" ] && echo "IP not found, check config file" && exit 1

DOMAIN="https://$IP"
CGI_PATH="redfish/v1/UpdateService/Oem/Supermicro/FirmwareInventory"
UPGRADE_PATH="Actions/SmcFirmwareInventory.Update"

TARGET_NAME=$1
case $TARGET_NAME in
    "BMC")
        ;;
    "BIOS")
        ;;
    *)
        echo "BMC or BIOS"
        exit 1;
        ;;
esac

DATA="{\"PreserveCfg\": true, \"PreserveSdr\": true, \"PreserveSsl\": true}"
URL="$DOMAIN/$CGI_PATH/$TARGET_NAME/$UPGRADE_PATH"

echo "Upgrading..."
ret=`curl $M_POST $URL --user $USER:$PASSWD -d "$DATA" -k 2>/dev/null | jq "." | grep "\"/redfish/v1/TaskService/Tasks/" | sed s/[[:space:]\"]//g`
[ -z "$ret" ] && echo "not found TaskService" && echo "$ret" && exit 1

echo "Processing..."
./fw_process.sh $ret
