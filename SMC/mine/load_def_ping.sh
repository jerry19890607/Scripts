#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#echo ${IPMI} ${RAW}
STOP="load_def_stop"

cnt=0
while [ 1 ]
do
    if [ -f $STOP ];then
        break;
    fi

    cnt=$((cnt + 1))
    printf "cnt: %04d\r" $cnt
    $IPMI ${RAW} 0x30 0x40 > /dev/null 2>&1

    while [ 1 ]
    do
        ping -c 1 -W 2 ${IP} > /dev/null
        if [ $? -eq 0 ]; then
            break;
        fi

        if [ -f $STOP ];then
            break;
        fi
        sleep 1
    done

    sleep 120
done
printf "\n"
