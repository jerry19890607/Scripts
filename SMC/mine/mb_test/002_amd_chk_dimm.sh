#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

DIMM_MUX_ADDR=0xE8
BUS_NO=`printf "0x%02X" $((0x05 * 2 + 1))`

#echo ${IP}
#DIMM NUBER / 8 : 0: 0~7, 1: 8~15, ...
DIMM_CH=$1
[ -z "$DIMM_CH" ] && echo "Please input dimm group id" && exit 1
CMD="0x06 0x52"
READ=0x00
WRITE=${DIMM_CH}
echo "${IPMI} ${RAW} ${CMD} ${BUS_NO} ${DIMM_MUX_ADDR} ${READ} ${WRITE}"
${IPMI} ${RAW} ${CMD} ${BUS_NO} ${DIMM_MUX_ADDR} ${READ} ${WRITE} > /dev/null
sleep 0.5
READ=0x01
echo "${IPMI} ${RAW} ${CMD} ${BUS_NO} ${DIMM_MUX_ADDR} ${READ}"
printf "chg to "
${IPMI} ${RAW} ${CMD} ${BUS_NO} ${DIMM_MUX_ADDR} ${READ}

# 0x30 0x34 0x38 0x3C
# 0x32 0x36 0x3A 0x3E
DIMM_ADDR="0x30 0x32 0x34 0x36 0x38 0x3A 0x3C 0x3E"
#DIMM_ADDR="0xA0 0xA2 0xA4 0xA6 0xA8 0xAA 0xAC 0xAE"
READ=0x02
WRITE=0x05
for addr in ${DIMM_ADDR}
do
    ret=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${addr} ${READ} ${WRITE} 2> /dev/null`
    if [ $? -eq 0 ];then
        echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${addr} ${READ} ${WRITE}
        v1=0x`echo $ret | awk -F' ' '{ printf $1 }'`
        v2=0x`echo $ret | awk -F' ' '{ printf $2 }'`
        #echo [$v1, $v2]
        echo "$addr: $((((v1 << 8) | v2) / 16)) C"
    fi
    sleep 0.1
done
