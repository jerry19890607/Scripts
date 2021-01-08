#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CPLD_ADDR=0x70
CMD="0x06 0x52"
READ_LEN=0x00

I2C_ID=$1
[ -z "$I2C_ID" ] && I2C_ID=3
BUS_NO=`printf "0x%02x" $((I2C_ID * 2 - 1))`
CH=$2
[ -z "$CH" ] && CH=0
MUX_CH=`printf "0x%02X" $((CH + 0x40))`
#echo $BUS_NO $MUX_CH

echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${CPLD_ADDR} ${READ_LEN} ${MUX_CH}
${IPMI} ${RAW} ${CMD} ${BUS_NO} ${CPLD_ADDR} ${READ_LEN} ${MUX_CH}
