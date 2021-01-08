#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CH=0x00
ME_ADDR=0x2C
CMD="0x04 0x2D 0x08"

echo ${IPMI} -b ${CH} -t ${ME_ADDR} raw ${CMD}
${IPMI} -b ${CH} -t ${ME_ADDR} raw ${CMD}
