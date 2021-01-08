#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CMD=$@
RAW=" raw 0x06 0x52"

echo ${IPMI} ${RAW} ${CMD}
${IPMI} ${RAW} ${CMD}
