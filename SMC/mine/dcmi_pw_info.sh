#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

CMD="-I lanplus dcmi power reading"
# ipmitool -I lanplus -H 10.138.160.97 -U ADMIN -P ADMIN dcmi power reading
echo ${IPMI} ${CMD} 
${IPMI} ${CMD} 
