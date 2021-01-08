#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

BUS_CH=0x05
RAW="raw"
CMD="0x06 0x52"
VPD_ADDR=0xA6
READ=0x5C
WRITE=0x00

MUX_ADDR=$1
[ -z "$MUX_ADDR" ] && echo "input to set mux addr" && exit 1
SET_MUX_CH=$2
[ -z "$SET_MUX_CH" ] && echo "input to set mux ch" && exit 1

READ_LEN=0x00
WRITE_DATA="${SET_MUX_CH}"

RET=`${IPMI} ${RAW} ${CMD} ${BUS_CH} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`

READ_LEN=0x01
RET=`${IPMI} ${RAW} ${CMD} ${BUS_CH} ${MUX_ADDR} ${READ_LEN} 2>&1`
echo $RET

ret=`${IPMI} ${RAW} ${CMD} ${BUS_CH} ${VPD_ADDR} ${READ} ${WRITE}`
echo $ret
VendorID=`echo $ret | awk -F' ' '{ print $5 $4 }'`


READ=0x02
WRITE=0x55
ret=`${IPMI} ${RAW} ${CMD} ${BUS_CH} ${VPD_ADDR} ${READ} ${WRITE}`
temp=`echo $ret | awk -F' ' '{ printf "%d", "0x"$2$1 }'`

echo VendorID: 0x$VendorID
echo "temp:" $temp "C"
