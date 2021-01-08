#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#raw 0x6 0x1
CMD="0x30 0x74 0x03"

PASSWORD=$1
[ -z "$PASSWORD" ] && PASSWORD="ADMIN"

PW_TO_ASSCII=""
for (( i = 0; i < ${#PASSWORD}; i++ )); do
    ASCII=0x`LC_CTYPE=C printf '%x\n' "'${PASSWORD:$i:1}"`
    PW_TO_ASSCII="$PW_TO_ASSCII $ASCII"
done

echo ${IPMI} ${RAW} ${CMD} ${PW_TO_ASSCII}
${IPMI} ${RAW} ${CMD} ${PW_TO_ASSCII}
