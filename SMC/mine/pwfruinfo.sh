#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

file=tmpFru.txt
rm -f $file
RAW="raw"
CMD="0x30 0xA1"
ID=$1
[ -z $ID ] && echo "input id" && exit 1

for (( i = 1; i <= 8; i++ )); do
    BLK_ID=`printf "0x%02x" $i`
    echo ${IPMI} ${RAW} ${CMD} ${ID} ${BLK_ID}
    RET=`${IPMI} ${RAW} ${CMD} ${ID} ${BLK_ID}`
    j=0
    #echo $RET
    for val in $RET
    do
        printf "0x$val " >> $file
        j=$((j+1))
        if [ $((j%16)) -eq 0 ];then
            printf "\n" >> $file
        fi
    done
done
printf "\n" >> $file
