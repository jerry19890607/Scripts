#!/bin/sh

IP=$1
IMAGE=$(cd "$(dirname "$2")"; pwd)/$(basename "$2")

echo $IMAGE

curl \
-k -X POST \
https://$IP/redfish/v1/UpdateService/upload \
-H 'Authorization: Basic QURNSU46QURNSU4=' \
-H 'cache-control: no-cache' \
-H 'content-type: multipart/form-data' \
-F UpdateFile=@//$IMAGE \
-F 'UpdateParameters={"Targets":["/redfish/v1/Managers/1"],"@Redfish.OperationApplyTime":" Immediate ","Oem":{"Supermicro": {"BMC": {"PreserveCfg": false,"PreserveSdr": true,"PreserveSsl": false,"BackupBMC": false}}}}'

echo ""
