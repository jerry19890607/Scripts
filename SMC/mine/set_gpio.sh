#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#ipmitool -H 10.138.160.69 -U ADMIN -P ADMIN raw 0x30 0x70 0xc2 0x17 0x00 0x00 0x00

CMD="0x30 0x70 0xc2"

GPIO_PIN=$1
[ -z "$GPIO_PIN" ] && echo "input GPIO Pin" && exit 1

${IPMI} ${RAW} ${CMD}
