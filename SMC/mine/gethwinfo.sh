#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw"
CMD="0x06 0x01"

${IPMI} ${RAW} ${CMD}
