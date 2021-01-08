#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

DEV_NO=0x00
RM_CMD_0="0x30 0x70 0xA3"
RM_CMD_1="${DEV_NO} 0xFF"
REMOVE_CMD="${RM_CMD_0} ${RM_CMD_1}"

max=60
cur=$max
end=0
while [ $cur -ne 0 ]
do
    cnt=0
    while [ 1 ]
    do
        #echo ${IPMI} ${RAW} ${REMOVE_CMD}
        ret=`${IPMI} ${RAW} ${REMOVE_CMD} > /dev/null > 2&>1;echo $?`
        if [ $ret -eq 0 ];then
            break;
        fi
        cnt=$((cnt+1))
        printf "cnt:%d\r" $cnt
        sleep 1
    done
    cur=$((cur-1))
    printf "%d> cnt: %d\r" $((max-cur)) $cnt
    if [ $cnt -eq 0 ];then
        sleep 1
    else
        end=$((end+1))
        sleep 3
    fi
done
echo ""
echo "end: $end"
