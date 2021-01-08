#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CMD="chassis bootparam get 0x05 -v"
echo ${IPMI} ${CMD}
${IPMI} ${CMD}

echo ${IPMI} ${RAW} 0x00 0x09 0x05 0x00 0x00
${IPMI} ${RAW} 0x00 0x09 0x05 0x00 0x00
