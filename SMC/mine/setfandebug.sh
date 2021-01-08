#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw"
CMD="0x30 0x70 0xfa $1"

echo ${IPMI} ${RAW} ${CMD}
${IPMI} ${RAW} ${CMD}
