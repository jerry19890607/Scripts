#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

#echo ${IPMI} ${RAW}
SENSOR_LIST_CMD="sensor list"
BMC_RESET_CMD="mc reset cold"
SEL_LIST_CMD="sel list"
cnt=0
DATE=`date +%Y%m%d_%H%M%S`
LOG=~/workspace/log/${DATE}_NVME_temp.txt
SELLOG=~/workspace/log/${DATE}_NVME_sel.txt

while [ 1 ]
do
    ping -c 1 -W 1 $IP > /dev/null 2>&1
    [ $? -ne 0 ] && continue

    cnt=$((cnt + 1))

    printf "%04d: =====================================\n" $cnt >> $LOG
    echo "${IPMI} ${SENSOR_LIST_CMD}" >> $LOG
    retry=10
    while [ 1 ]
    do
        ret=`${IPMI} ${SENSOR_LIST_CMD}`
        temp=`echo $ret | grep "NVMe_SSD" | awk -F'|' '{ print $2 }'`
        case $temp in
            "na")
                ;;
            *)
                break;
        esac

        retry=$((retry - 1))
        if [ $retry -eq 0 ];then
            echo "$cnt: NVMe_SSD fail"
            echo "$cnt: NVMe_SSD fail" >> $LOG
            ${IPMI} ${SEL_LIST_CMD} >> $SELLOG
            echo "$cnt: $ret" > $LOG
            exit 1
        fi
        sleep 30
    done

    echo "$ret" >> $LOG

    printf "%04d: =====================================\n" $cnt >> $SELLOG
    ret=`${IPMI} ${SEL_LIST_CMD}` >> $SELLOG
    echo $ret >> $SELLOG

    sel_data=`echo $ret | grep "Group.*Slot.*Ejected.*Assertion"`
    if [ ! -z $sel_data  ];then
        echo "SEL fail $sel_data"
        break;
    fi

    ${IPMI} ${BMC_RESET_CMD} > /dev/null 2>&1
    sleep 120
done
