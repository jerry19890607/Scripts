#!/bin/sh

ARGUNUM=$#
TYPE=$1
IP=$2
FW_IMAGE=$(cd "$(dirname "$3")"; pwd)/$(basename "$3")

# USER/PWD
NAME=ADMIN
PASSWORD=ADMIN
cred="$( echo -n $NAME:$PASSWORD | base64 )"

usage () {
    echo -e "Usage:"
    echo -e " FwUpdate.sh (bmc|bios) IP_ADDR FW_IMAGE"
    echo -e ""
}

if [ $ARGUNUM != 3 ]; then
    echo ""
    usage
    exit
fi

echo [$TYPE][$IP][$cred][$FW_IMAGE]

#BMC
if [ $TYPE == "bmc" ]; then
    curl \
    -k -X POST \
    https://$IP/redfish/v1/UpdateService/upload \
    -H "Authorization: Basic $cred" \
    -H 'cache-control: no-cache' \
    -H 'content-type: multipart/form-data' \
    -F UpdateFile=@//$FW_IMAGE \
    -F 'UpdateParameters={"Targets":["/redfish/v1/Managers/1"],"@Redfish.OperationApplyTime":" Immediate ","Oem":{"Supermicro": {"BMC": {"PreserveCfg": false,"PreserveSdr": true,"PreserveSsl": false,"BackupBMC": false}}}}'

    echo ""
    exit;
fi

#BIOS
if [ $TYPE == "bios" ]; then
    curl \
    -k -X POST \
    https://$IP/redfish/v1/UpdateService/upload \
    -H "Authorization: Basic $cred" \
    -H 'cache-control: no-cache' \
    -H 'content-type: multipart/form-data' \
    -F UpdateFile=@//$FW_IMAGE \
    -F 'UpdateParameters={"Targets":["/redfish/v1/Systems/1/Bios"],"@Redfish.OperationApplyTime":" Immediate ","Oem":{"Supermicro": {"BIOS": {"PreserveME": false,"PreserveNVRAM": true,"PreserveSMBIOS": false,"BackupBIOS": false}}}}'

    echo ""
    exit;
fi

usage
echo ""
