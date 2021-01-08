#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CMD="0x06 0x52"
BUS=0x01

for (( i = 0; i < 256; i++ )); do
    addr=`printf "0x%02x" $i`
    ret=`${IPMI} ${RAW} ${CMD} ${BUS} ${addr} 0x01 0x00 > /dev/null 2>&1`
    if [ $? -eq 0 ];then
        echo ${addr}
    fi
done
