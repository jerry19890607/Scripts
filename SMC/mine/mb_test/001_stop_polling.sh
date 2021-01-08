#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW_CMD="raw 0x30 0x70 0xdf"

WRITE=$1

echo $IPMI ${RAW_CMD} ${WRITE}
$IPMI ${RAW_CMD} ${WRITE}
