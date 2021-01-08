#!/bin/bash

filename=$1
[ -z "$filename" ] || [ ! -f "$filename" ] && echo "$filename not found" && exit 1

TYPE=BMC

./chk_task.sh
sleep 1
./fw_update_mode.sh $TYPE
sleep 1
./fw_upload.sh $TYPE $filename
sleep 1
./fw_upgrade.sh $TYPE
