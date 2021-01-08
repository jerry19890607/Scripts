#!/bin/bash
. config

[ -z "$IP" ] && echo "IP not found, check config file" && exit 1

DOMAIN="https://$IP"
CGI_PATH="redfish/v1/UpdateService/Oem/Supermicro/FirmwareInventory"
EXPECT_HEADER="Expect:"
UPLOAD_PATH="Actions/SmcFirmwareInventory.Upload"

TARGET_NAME=$1
case $TARGET_NAME in
    "BMC")
        ;;
    "BIOS")
        ;;
    *)
        echo "BMC or BIOS"
        exit 1
        ;;
esac

filename=$2
[ -z "$filename" ] || [ ! -f "$filename" ] && echo "$filename not found" && exit 1

URL="$DOMAIN/$CGI_PATH/$TARGET_NAME/$UPLOAD_PATH"

QSTR_1="-F UpdateFile=@$filename"

#echo curl $M_POST $URL --user $USER:$PASSWD -H "$EXPECT_HEADER" "$QSTR_1" -k
echo "Uploading..."
curl $M_POST $URL --user $USER:$PASSWD -H "$EXPECT_HEADER" "$QSTR_1" -k 2>/dev/null | jq "."
