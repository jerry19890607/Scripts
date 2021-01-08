#!/bin/bash
. ../config

DOMAIN="https://$IP"
#CGI_PATH="redfish/v1/UpdateService/update"
CGI_PATH="redfish/v1/UpdateService/FirmwareInventory"
URL="$DOMAIN/$CGI_PATH/"
EXPECT_HEADER="Expect:"

filename=$1
[ -z "$filename" ] || [ ! -f "$filename" ] && echo "$filename not found" && exit 1

TARGET_NAME=$2

case $TARGET_NAME in
    "DCPMM")
        TARGET="/redfish/v1/UpdateService/FirmwareInventory/DCPMM"
        TASK="OnReset"
        ;;
    "BMC")
        TARGET="/redfish/v1/Systems/1/"
        TASK="Immediate"
        ;;
    "BIOS")
        TARGET="/redfish/v1/Systems/1/Memory/1"
        TASK="OnReset"
        ;;
    *)
        TARGET="/redfish/v1/UpdateService/FirmwareInventory/DCPMM"
        TASK="OnReset"
        ;;
esac

QSTR_1="-F UpdateParameters={\"Targets\":[\"$TARGET\"], \"@Redfish.OperationApplyTime\":\"$TASK\"}"
QSTR_2="-F UpdateFile=@$filename"

curl $M_POST $URL --user $USER:$PASSWD -H "$EXPECT_HEADER" "$QSTR_1" "$QSTR_2" -k 2>/dev/null | jq "."
