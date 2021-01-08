#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#raw 0x6 0x1
CMD="0x06 0x01"
echo ${IPMI} ${RAW} ${CMD}
ret=`${IPMI} ${RAW} ${CMD}`
[ $? -ne 0 ] && echo "$ret" && exit 1
echo $ret

BOARD_ID=""
VER=""
idx=0
for data in $ret
do
    case $idx in
        2)
            VER="${data}"
            ;;
        3|11)
            VER="${VER}.${data}"
            ;;
        9|10)
            BOARD_ID="$data$BOARD_ID"
            ;;
        12)
            case $data in
                "00")
                    stat="Standard non-signed"
                    ;;
                "01")
                    stat="Standard signed"
                    ;;
                "10")
                    stat="Beta non-signed"
                    ;;
                "11")
                    stat="Beta signed"
                    ;;
                "20")
                    stat="OEM non-signed"
                    ;;
                "21")
                    stat="OEM signed"
                    ;;
                "03")
                    stat="x12 Product key"
                    ;;
                "04")
                    stat="x12 Debug key"
                    ;;
            esac
            ;;
    esac

    idx=$((idx + 1))
done

printf "%-10s: %s\n" "BOARD_ID" "0x$BOARD_ID"
printf "%-10s: %s\n" "VER" "$VER"
printf "%-10s: %s\n" "STATUS" "$stat"
