#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw"
[ -z $1 ] && echo "input value 0x00 ~ 0xFF" && exit 1
CMD="0x30 0x70 0xFB 0x01 $1"

${IPMI} ${RAW} ${CMD}
