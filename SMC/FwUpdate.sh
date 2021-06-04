#!/bin/sh
# 2021-05-27 Create by JerryShih

ARGUNUM=$#
TYPE=$1
IP=$2
FW_IMAGE=$(cd "$(dirname "$3")"; pwd)/$(basename "$3")

# -- USER/PWD --
NAME=ADMIN
PASSWORD=ADMIN
cred="$( echo -n $NAME:$PASSWORD | base64 )"

# OnStartUpdateRequest or Immediate
APPLYTIME=Immediate

# -- BMC Parameters --
PRESERVE_CFG=false
PRESERVE_SDR=true
PRESERVE_SSL=false
BACKUP_BMC=false

# -- BIOS Parameters --
PRESERVE_ME=false
PRESERVE_NVRAM=true
PRESERVE_SMBIOS=false
BACKUP_BIOS=false


usage () {
    echo -e "Usage:"
    echo -e ""
    echo -e "   FwUpdate.sh (bmc|bios|cpld) IP_ADDR FW_IMAGE"
    echo -e ""
}

if [ $ARGUNUM != 3 ]; then
    echo ""
    usage
    exit
fi

if expr "$IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
    for i in 1 2 3 4; do
        if [ $(echo "$IP" | cut -d. -f$i) -gt 255 ]; then
            echo "Invalid IP ($IP)"
            echo ""
            usage
            exit
        fi
    done
else
    echo "Invalid IP ($IP)"
    echo ""
    usage
    exit
fi

echo [$TYPE] [$IP] [$cred] [$FW_IMAGE]

#BMC
if [ $TYPE == "bmc" ]; then
    echo  -e "\e[38;5;120m BMC FW image upload...\e[0m"
    curl \
    -k -X POST https://$IP/redfish/v1/UpdateService/upload \
    -H "Authorization: Basic $cred" \
    -H 'cache-control: no-cache' \
    -H 'content-type: multipart/form-data' \
    -F UpdateFile=@//$FW_IMAGE \
    -F "UpdateParameters={
            \"Targets\":[\"/redfish/v1/Managers/1\"],
            \"@Redfish.OperationApplyTime\":\"$APPLYTIME\",
            \"Oem\":{\"Supermicro\": {\"BMC\": {\"PreserveCfg\": $PRESERVE_CFG,\"PreserveSdr\": $PRESERVE_SDR,\"PreserveSsl\": $PRESERVE_SSL,\"BackupBMC\": $BACKUP_BMC}}}
       }"

    echo ""
    exit;
fi

#BIOS
if [ $TYPE == "bios" ]; then
    echo  -e "\e[38;5;120m BIOS FW image upload...\e[0m"
    curl \
    -k -X POST https://$IP/redfish/v1/UpdateService/upload \
    -H "Authorization: Basic $cred" \
    -H 'cache-control: no-cache' \
    -H 'content-type: multipart/form-data' \
    -F UpdateFile=@//$FW_IMAGE \
    -F "UpdateParameters={
            \"Targets\":[\"/redfish/v1/Systems/1/Bios\"],
            \"@Redfish.OperationApplyTime\":\"$APPLYTIME\",
            \"Oem\":{\"Supermicro\": {\"BIOS\": {\"PreserveME\": $PRESERVE_ME,\"PreserveNVRAM\": $PRESERVE_NVRAM,\"PreserveSMBIOS\": $PRESERVE_SMBIOS,\"BackupBIOS\": $BACKUP_BIOS}}}
        }"

    echo ""
    exit;
fi

#CPLD
if [ $TYPE == "cpld" ]; then
    echo  -e "\e[38;5;120m CPLD FW image upload...\e[0m"
    curl \
    -k -X POST https://$IP/redfish/v1/UpdateService/upload \
    -H "Authorization: Basic $cred" \
    -H 'cache-control: no-cache' \
    -H 'content-type: multipart/form-data' \
    -F UpdateFile=@//$FW_IMAGE \
    -F 'UpdateParameters={
            "Targets":["/redfish/v1/UpdateService/FirmwareInventory/CPLD_Motherboard"],
            "@Redfish.OperationApplyTime":"Immediate"
        }'

    echo ""
    exit;
fi

usage
echo ""
