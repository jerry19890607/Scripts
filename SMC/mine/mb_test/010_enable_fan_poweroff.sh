#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

case $1 in
    1)
        echo "enable"
        ENABLE=0x08
        ;;
    *)
        echo "disable"
        ENABLE=0x00
        ;;
esac

#ipmitool -H 10.138.160.66 -U ADMIN -P ADMIN raw 0x06 0x52 0x03 0x70 0x01 0x00 0x00
CMD="0x06 0x52"
BUS_ID=0x03
ADDR=0x70
READ=0x00
WRITE="0x00 $ENABLE"
echo ${IPMI} ${RAW} ${CMD} ${BUS_ID} ${ADDR} ${READ} ${WRITE}
${IPMI} ${RAW} ${CMD} ${BUS_ID} ${ADDR} ${READ} ${WRITE}
