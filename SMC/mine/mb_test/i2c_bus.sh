#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

I2C_CH=$1
[ -z "$I2C_CH" ] && echo "input I2C BusNo" && exit 1

I2C_SMBUS=`printf "0x%02x" $((I2C_CH * 2 + 1))`

ADDR=$2
[ -z "$ADDR" ] && echo "input salve address" && exit 1

WRITE=$3

CMD="0x06 0x52"
READ=0x1
echo ${IPMI} ${RAW} ${CMD} ${I2C_SMBUS} ${ADDR} ${READ} ${WRITE}
${IPMI} ${RAW} ${CMD} ${I2C_SMBUS} ${ADDR} ${READ} ${WRITE}
