#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#System Temp, RT1
#Rear side Temp, RT2

BUS=0x07
CH=`printf "0x%02x" $((BUS*2+1))`
ADDR=0x98
raw="raw 0x06 0x52"

READ=0x01
WRITE=0x00
echo "System:"
$IPMI $raw $CH $ADDR $READ $WRITE

WRITE=0x01
echo "Peripheral:"
$IPMI $raw $CH $ADDR $READ $WRITE
