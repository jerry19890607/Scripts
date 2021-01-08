#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x0a 0x44"

#CPU: 0x07, OEM CPU: 0xC3
TYPE=0xC3
#0x05
OFFSET=0x04
OEM_DATA_1=$1
OEM_DATA_2=$2
[ -z $OEM_DATA_1 ] || [ -z $OEM_DATA_2 ] && echo "Please input OEM DATA 1 & 2" && exit 1

     #00 00 02 00 00 00 00 04 00 04 07 ff 6f 05 ff ff
DATA="0x05 0x00 0x02 0x44 0xB4 0x90 0x5C 0x21 0x00 0x04 $TYPE 0x00 0x6F $OFFSET $OEM_DATA_1 $OEM_DATA_2"
echo ${IPMI} ${RAW} ${DATA}
${IPMI} ${RAW} ${DATA}

sleep 0.5

DATA="0x05 0x00 0x02 0x44 0xB4 0x90 0x5C 0x21 0x00 0x04 $TYPE 0x00 0xEF $OFFSET $OEM_DATA_1 $OEM_DATA_2"
echo ${IPMI} ${RAW} ${DATA}
${IPMI} ${RAW} ${DATA}
