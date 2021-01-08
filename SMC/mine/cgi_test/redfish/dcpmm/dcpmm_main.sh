#!/bin/bash
. ../config

MEM_INFO=./dcpmm_detail.sh
UPLOAD=./dcpmm_upload.sh
PW_CTRL=./host_pw_ctrl.sh
MAX_CHK_VER_NUM=10
MAX_REBOOT_TIMEOUT=150

myprintf ()
{
    curDateTime=`date +"%Y/%m/%d %H:%M:%S"`
    printf "$curDateTime >> $@"
}

getMemVerInfo ()
{
    ID=$1

    ret=`$MEM_INFO $ID | jq ".FirmwareRevision"`
    ret=${ret//\"/}
    #printf "MEM%02d_Ver=%s" $ID $ret
    echo $ret
}

host_reboot ()
{
    #reboot host
    myprintf "Power off...\n" >> $LOG
    $PW_CTRL ForceOff >> $LOG
    sleep 10
    myprintf "Power on...\n" >> $LOG
    $PW_CTRL ForceOn >> $LOG
}

FILE_1=$1
FILE_2=$2
[ -z "$FILE_1" ] || [ -z "$FILE_2" ] || [ ! -f "$FILE_1" ] || [ ! -f "$FILE_2" ] && echo "[$FILE_1] or [$FILE_2] not found" && exit 1

host=""
cnt=0
LOG=$IP_`date +%Y%m%d_%H%M`_dcpmm.log
CUR_FW_REV=""

while [ 1 ]
do
#{
    if [ $((cnt % 2)) -eq 0 ];then
        FILE=$FILE_1
    else
        FILE=$FILE_2
    fi

    FILE_NAME=`echo $FILE | awk -F'.' '{printf $1}' | tr '_' '.'`
    EXPECT_FW_REV="$FILE_NAME $FILE_NAME"

    cnt=$((cnt + 1))
    curDateTime=`date +"%Y/%m/%d %H:%M:%S"`
    echo "=================== $cnt: $curDateTime ===================" >> $LOG
    CUR_FW_REV="`getMemVerInfo 2` `getMemVerInfo 4`"

    myprintf "upload...\n" >> $LOG
    $UPLOAD $FILE | jq ".[].Message" >> $LOG

    sleep 5

    #reboot host: first, BIOS get DCPMM fw
    host_reboot

    #ping host
    if [ ! -z "$host" ] ;then
        myprintf "ping host...\n" >> $LOG
        while [ 1 ]
        do
            ret=`ping $host -W 1 -c 1`
            [ $? -eq 0 ] && break
        done
    else
        sleep $MAX_REBOOT_TIMEOUT
    fi

    myprintf "check ver...\n" >> $LOG
    chkVerCnt=0
    while [ 1 ]
    do
        NEW_FW_REV="`getMemVerInfo 2` `getMemVerInfo 4`"
        case "${NEW_FW_REV}" in
            "${EXPECT_FW_REV}")
                myprintf "%-10s:%30s\n" "Current" "$CUR_FW_REV" >> $LOG
                myprintf "%-10s:%30s\n" "New" "$NEW_FW_REV" >> $LOG
                myprintf "upgrade success\n" >> $LOG
                break
                ;;
            *)
                if [ $chkVerCnt -eq 0 ];then
                    chkVerCnt=$MAX_CHK_VER_NUM
                    #reboot host: second, BIOS upgrade DCPMM fw
                    host_reboot

                    sleep $MAX_REBOOT_TIMEOUT
                else
                    chkVerCnt=$((chkVerCnt - 1))
                fi
                sleep 1
                ;;
        esac
    done

    sleep 20
#}
done
