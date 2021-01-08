#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x00 0x02"
CMD="0x02"
OS_IP=10.138.160.231
TOTAL=0
while [ 1 ]
do
    $IPMI $RAW $CMD > /dev/null 2>&1
    sleep 10

    while [ 1 ]
    do
        ping ${OS_IP} -c 1 -W 1 > /dev/null 2>&1
        [ $? -eq 0 ] && break
        sleep 5
    done
    cnt=90
    while [ $cnt -ne 0 ]
    do
        val=$((cnt % 3))
        case $val in
            2)
                printf "%06d:%02d%-3s\r" $TOTAL $cnt "."
                ;;
            1)
                printf "%06d:%02d%-3s\r" $TOTAL $cnt ".."
                ;;
            0)
                printf "%06d:%02d%-3s\r" $TOTAL $cnt "..."
                ;;
        esac
        cnt=$((cnt - 1))
        sleep 1
    done
    TOTAL=$((TOTAL+1))
    printf "%-6d" $TOTAL
done
