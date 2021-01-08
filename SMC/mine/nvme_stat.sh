#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@
# raw 0x30 0x70 0x6C 0x00 0x00 0x00 0x00 0x00
NVME_CMD="0x30 0x70 0x6C"
# Set: 0x01
ACTION=0x00
AOC_NUM=0x00
SLOT_ID=0x00
OPTION=0x02
NVME_ID=0x00

echo ${IPMI} ${RAW} ${NVME_CMD} ${ACTION} ${AOC_NUM} ${SLOT_ID} ${OPTION} ${NVME_ID}
RET=`${IPMI} ${RAW} ${NVME_CMD} ${ACTION} ${AOC_NUM} ${SLOT_ID} ${OPTION} ${NVME_ID}`

echo $RET
LOCATE_L=`comm_getValueByRange "$RET" 2 0`
LOCATE_L=`printf "%d" $LOCATE_L`
echo $LOCATE_L
#echo $((2#${LOCATE_L}))
#echo "ibase=16,obase=2;$LOCATE_L" | bc

PRESENT=`comm_getValueByRange "$RET" 2 1`
echo $PRESENT
