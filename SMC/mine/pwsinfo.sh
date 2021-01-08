#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x06 0x52"
BUS_NO=0x03
CH=`printf "0x%02x" $((BUS_NO * 2 + 1))`
BUF=0x97
#BUF=0x0C
S_ADDR=$1
[ -z $S_ADDR ] && echo "input slave addr" && exit 1

$IPMI $RAW $CH $S_ADDR 0x01 $BUF
