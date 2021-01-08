#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#ipmitool -H xx.xxx.xxx.xx -U ADMIN -P ADMIN raw 0x6 0x52 0x3 0x70 0x1 0x8 0x30

case $1 in
    0)
        ctrl=0x00
        ;;
    1)
        ctrl=0x10
        ;;
    2)
        ctrl=0x20
        ;;
    3)
        ctrl=0x30
        ;;
    *)
        echo "ctrl fail, please input 0 ~ 3"
        exit 1
        ;;
esac

CMD="0x06 0x52"
BUS_ID=0x03
ADDRESS=0x70
READ=0x01
WRITE="0x08 $ctrl"

echo ${IPMI} ${RAW} ${CMD} ${BUS_ID} ${ADDRESS} ${READ} ${WRITE}
${IPMI} ${RAW} ${CMD} ${BUS_ID} ${ADDRESS} ${READ} ${WRITE}
