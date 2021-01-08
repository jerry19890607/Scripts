#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

raw="raw 0x06 0x52"
BUSID=0x03
CHID=`printf "0x%02x" $(((BUSID*2) + 1))`
#0x80, 0x86
SLV_ADDR=$1
READ=0x01
WRITE=0xfd

[ -z $SLV_ADDR ] && echo "input slave address" && exit 1
echo $IPMI $raw $CHID $SLV_ADDR $READ $WRITE
printf "Type:"
$IPMI $raw $CHID $SLV_ADDR $READ $WRITE

READ=0x02
WRITE=0xFE
echo $IPMI $raw $CHID $SLV_ADDR $READ $WRITE
printf "Ver:"
$IPMI $raw $CHID $SLV_ADDR $READ $WRITE

READ=0x01
WRITE=0x22
echo $IPMI $raw $CHID $SLV_ADDR $READ $WRITE
printf "temp:"
$IPMI $raw $CHID $SLV_ADDR $READ $WRITE
