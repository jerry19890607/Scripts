#!/bin/bash
. config

[ -z "$IP" ] && echo "IP not found, check config file" && exit 1

DOMAIN="https://$IP"
CGI_PATH="redfish/v1/UpdateService/Oem/Supermicro/FirmwareInventory"
UPDATE_MODE_PATH="Actions/SmcFirmwareInventory.EnterUpdateMode"

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

DATA="{}"
URL="$DOMAIN/$CGI_PATH/$TARGET_NAME/$UPDATE_MODE_PATH"

echo "Switch update mode..."
curl $M_POST $URL --user $USER:$PASSWD -d $DATA -k 2>/dev/null | jq "."
