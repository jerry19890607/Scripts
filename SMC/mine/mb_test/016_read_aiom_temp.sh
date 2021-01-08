#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

I2C_ID=$1
[ -z "$I2C_ID" ] && I2C_ID=3
BUS_NO=`printf "0x%02x" $((I2C_ID * 2 - 1))`

CMD="0x06 0x52"

ADDRS="0x98 0x3E"
REGS="0x00 0x01"
READ_LEN="0x01"

for addr in $ADDRS
do
    for reg in $REGS
    do
        temp=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${addr} ${READ_LEN} ${reg} 2>&1`
        if [ $? -eq 0 ];then
            echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${addr} ${READ_LEN} ${reg}
            temp="0x${temp#"${temp%%[![:space:]]*}"}"
            printf "Temp[%s,%s]: %d 'C\n" ${addr} ${reg} ${temp}
            exit 0
        fi
        sleep 0.5
    done
done

