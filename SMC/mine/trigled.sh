#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x30 0x70 0x65"
DATA=$1
echo ${IPMI} ${RAW} ${DATA}
${IPMI} ${RAW} ${DATA}
