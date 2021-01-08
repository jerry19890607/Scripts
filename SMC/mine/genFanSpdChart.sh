#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="sdr list"
DATAS=`${IPMI} ${RAW} | grep "CPU Temp\|FAN.*ok"`
tmp=$IFS
IFS='\n'

#while [ 0 ]
#do
    [ -f ./stopfan ] && echo "finish" && break

    for data in $DATAS
    do 
        echo $data | awk -F'|' '{
            NAME=gsub(/ /, "", $1);
            VAL=$2;
            printf NAME","VAL"\n";
        }'
        #| tr -d ' '
    done
#done
IFS=$tmp
#fan1: 4800
#fan4: 2900
