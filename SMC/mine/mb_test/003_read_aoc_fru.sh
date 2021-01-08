#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@
CMD="0x06 0x52"

I2C_NO=$1
BUS_NO=`printf "0x%02X" $(((I2C_NO - 1) * 2 + 1))`
[ -z "$I2C_NO" ] && echo "$0 [I2C_NO]" && exit 1

if [ -z "$2" ]; then
    AOC_ADDR=0xa0
else
    AOC_ADDR=$2
fi
READ=100
WRITE=0x00
echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${AOC_ADDR} ${READ} ${WRITE}
ret=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${AOC_ADDR} ${READ} ${WRITE}`

cnt=0
for val in $ret
do
    printf "0x"$val" "
    cnt=$((cnt + 1))
    if [ $((cnt % 8)) == 0 ];then
        printf "\n"
    fi
done
echo "==="
cnt=0
for val in $ret
do
    echo 0x$val | xxd -r
    #printf " "
    #cnt=$((cnt + 1))
    #if [ $((cnt % 8)) == 0 ];then
    #    printf "\n"
    #fi
done
echo ""
