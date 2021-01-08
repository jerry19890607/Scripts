#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CMD="raw 0x30 0x70 0x66"
ISGET=$1
case $ISGET in
    "set")
        REGION=$2
        DUTY_CYCLE=$3
        [ -z $REGION ] || [ -z $DUTY_CYCLE ] && echo "input region and duty cycle" && exit 1
        WRITE="0x01 $REGION $DUTY_CYCLE"
        REGION=`echo $WRITE | awk -F' ' '{ printf $2 }'`
        echo ${IPMI} ${CMD} ${WRITE}
        ${IPMI} ${CMD} ${WRITE}
        sleep 0.5
        ;;
    "get")
        REGION=$2
        [ -z $REGION ] && echo "input region" && exit 1
        ;;
esac

READ="0x00 $REGION"
echo ${IPMI} ${CMD} ${READ}
${IPMI} ${CMD} ${READ}

# rpm ...etc.
# cat /sys/class/hwmon/hwmon0/device/
# show fan debug log
# ipmitool -H 10.138.160.36 -U ADMIN -P ADMIN raw 0x30 0x70 0xfa 0x01
