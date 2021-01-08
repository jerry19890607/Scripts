#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

function getDataSize
{
    CMD=$1
    cnt=0
    for c in $CMD
    do
        cnt=$((cnt+1))
    done
    echo $cnt
}

function mysleep
{
    n=$1
    cmd=$2
    str=""
    printf "%-10s: %-40s\r" "${cmd}" "${str}"
    while [ $n -ne 0 ]
    do
        n=$((n-1))
        str="${str}."
        printf "%-10s: %-10s\r" "${cmd}" "${str}"
        sleep 1
    done
}

#"op=Add_BrcmStorCtrlLogDrvConf.XML&r=(0,0)&existing=0&span=1&num=2&index=4:5
#&percentage=100&lds=0&strip=2&name=&rPolicy=0&wPolicy=1&ioPolicy=0&aPolicy=0
#&cPolicy=0&init=0"
DEV_NO=0x00
RAID_TYPE=0x00
RAID_SPAN=0x01
RAID_PERCENTAGE=0x64
RAID_LDS=0x01
RAID_STRIP=0x02
RAID_NAME="0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00"
RAID_R_POLICY=0x00
RAID_W_POLICY=0x01
RAID_IO_POLICY=0x00
RAID_A_POLICY=0x00
RAID_C_POLICY=0x00
RAID_INIT=0x00
RAID_NUM=0x02

RAID_DISK_EMPTY="0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 "

RAID_DISK_CUR_INDEX="0x30"
RAID_DISK_INDEX="0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 "
RAID_DISK_INDEX+=${RAID_DISK_EMPTY}
RAID_DISK_INDEX+=${RAID_DISK_EMPTY}

CMD_0="0x30 0x70 0xA1"
CMD_1="${DEV_NO} ${RAID_TYPE} ${RAID_SPAN} ${RAID_PERCENTAGE} ${RAID_LDS} ${RAID_STRIP} ${RAID_NAME}"
CMD_2="${RAID_R_POLICY} ${RAID_W_POLICY} ${RAID_IO_POLICY} ${RAID_A_POLICY} ${RAID_C_POLICY}"
CMD_3="${RAID_INIT} ${RAID_NUM} ${RAID_DISK_CUR_INDEX} ${RAID_DISK_INDEX}"

LOG_INDEX=0x00

RM_CMD_0="0x30 0x70 0xA3"
RM_CMD_1="${DEV_NO} 0xFF"
REMOVE_CMD="${RM_CMD_0} ${RM_CMD_1}"

REBOOT_CMD="0x06 0x02"

GET_CARD_INFO_CMD="0x30 0x70 0xA0"
QUERY_LOG_CMD="0x30 0x70 0xA8 ${LOG_INDEX} ${DEV_NO}"

echo "create cmd size=" `getDataSize "${CREATE_CMD}"`
echo "remove cmd size=" `getDataSize "${REMOVE_CMD}"`

echo "================= start ====================="
val=`${IPMI} ${RAW} ${GET_CARD_INFO_CMD}`
[ $? -ne 0 ] && echo "get info fail" && break;
val=`comm_getValueByRange "$val" 0 20`
val=`comm_toString "$val"`
echo "Name:" ${val}

TIMEOUT=5
max=15
cnt=2
OUTPUT_FILE=raid.txt
while [ 1 ]
do
    _type=$((cnt % 5))
    case $_type in
        0)#RAID 0
            RAID_TYPE=0x00
            RAID_DISK_CUR_INDEX=0x03
            RAID_NUM=0x02
            RAID_SPAN=0x01
            ;;
        1)#RAID 1
            RAID_TYPE=0x01
            ;;
        2)#RAID 5
            #"op=Add_BrcmStorCtrlLogDrvConf.XML&r=(0,2)&existing=0&span=1&num=4&index=0:1:2:3
            #&percentage=100&lds=0&strip=2&name=&rPolicy=0&wPolicy=1&ioPolicy=0&aPolicy=0&cPolicy=0&init=0"
            RAID_TYPE=0x02
            RAID_DISK_CUR_INDEX=0x0f
            RAID_NUM=0x04
            ;;
        3)#RAID 6
            RAID_TYPE=0x03
            ;;
        4)#RAID 10
            RAID_TYPE=0x04
            RAID_SPAN=0x02
            ;;
    esac
    CMD_1="${DEV_NO} ${RAID_TYPE} ${RAID_SPAN} ${RAID_PERCENTAGE} ${RAID_LDS} ${RAID_STRIP} ${RAID_NAME}"
    CMD_3="${RAID_INIT} ${RAID_NUM} ${RAID_DISK_CUR_INDEX} ${RAID_DISK_INDEX}"

    #To create RAID
    CREATE_CMD="${CMD_0} ${CMD_1} ${CMD_2} ${CMD_3}"
    ret=`${IPMI} ${RAW} ${CREATE_CMD}`
    ret2=$?
    ret=`printf "%d" "0x$ret"`
    if [ $ret -ne 0 ] || [ $ret2 -ne 0 ]; then
        printf "\ncreate RAID(0x%02x) ... 0x%02x\n" $RAID_TYPE $ret
        #echo "[${IPMI} ${RAW} $CREATE_CMD]"
        #echo "create cmd size=" `getDataSize "${CMD_0}"` "$CMD_0"
        #echo "create cmd size=" `getDataSize "${CMD_1}"` "$CMD_1"
        #echo "create cmd size=" `getDataSize "${CMD_2}"` "$CMD_2"
        #echo "create cmd size=" `getDataSize "${CMD_3}"` "$CMD_3"
        break;
    fi

    # To check RAID Size, if getting the size then next
    size=0
    retry=0
    while [ 1 ]
    do
        ret=`${IPMI} ${RAW} ${QUERY_LOG_CMD}`
        size=`echo $ret | awk -F' ' '{printf "%d", "0x"$2$1}'`
        [ $size -ne 0 ] || [ $retry -eq $max ] && break
        retry=$((retry+1))
        mysleep 1 "create type(${RAID_TYPE}) waitting ... $size GB"
    done
    [ $retry -eq $max ] && echo "" && echo "retry $max times" && break
    mysleep ${TIMEOUT} "$cnt: Success, type(${RAID_TYPE}) ... $size GB"
    echo "$cnt: Success, type(${RAID_TYPE}) ... $size GB" >> $OUTPUT_FILE

    #To remove RAID
    ret=`${IPMI} ${RAW} ${REMOVE_CMD}`
    ret2=$?
    ret=`printf "%d" $ret`
    if [ $ret -ne 0 ] || [ $ret2 -ne 0 ];then
        printf "\nremove RAID ... 0x%02x\n" $ret
        break;
    fi
    mysleep ${TIMEOUT} "remove waitting"

    cnt=$((cnt+1))
done
echo "$cnt: fail, type(${RAID_TYPE}) ... $size GB" >> $OUTPUT_FILE
echo "retry: $retry" >> $OUTPUT_FILE
