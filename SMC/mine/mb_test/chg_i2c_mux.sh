#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#0xE8
I2C_NO=$1
MUX_ADDR=$2
BUS_NO=`printf "0x%02X" $(((I2C_NO - 1) * 2 + 1))`
MUX_CH=$3

[ -z "$MUX_ADDR" ] && echo "$0 [I2C_NO] [MUX_ADDR] [MUX_CH]" && exit 1
[ -z "$I2C_NO" ] && echo "$0 [I2C_NO] [MUX_ADDR] [MUX_CH]" && exit 1
[ -z "$MUX_CH" ] && echo "$0 [I2C_NO] [MUX_ADDR] [MUX_CH]" && exit 1

CMD="0x06 0x52"
READ=0x00
WRITE=${MUX_CH}
echo "${IPMI} ${RAW} ${CMD} ${BUS_NO} ${MUX_ADDR} ${READ} ${WRITE}"
${IPMI} ${RAW} ${CMD} ${BUS_NO} ${MUX_ADDR} ${READ} ${WRITE}
sleep 0.5
READ=0x01
echo "${IPMI} ${RAW} ${CMD} ${BUS_NO} ${MUX_ADDR} ${READ}"
${IPMI} ${RAW} ${CMD} ${BUS_NO} ${MUX_ADDR} ${READ}

#ipmitool -H 10.138.160.97 -U ADMIN -P ADMIN raw 0x06 0x52 0x01 0x60 0x1 0xb4
