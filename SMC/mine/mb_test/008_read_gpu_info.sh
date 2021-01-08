#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x06 0x52"

debug=0

to_err_msg ()
{
    err_no=$1
    case $err_no in
        "0x00")
            echo "NULL"
            ;;
        "0x01")
            echo "Err Request"
            ;;
        "0x02")
            echo "Err OP code"
            ;;
        "0x03")
            echo "Err ARG 1"
            ;;
        "0x04")
            echo "Err ARG 2"
            ;;
        "0x05")
            echo "Err Data"
            ;;
        "0x06")
            echo "Err Misc"
            ;;
        "0x07")
            echo "Err i2c access"
            ;;
        "0x08")
            echo "Err not Supported"
            ;;
        "0x09") echo "Err not Avilable"
            ;;
        "0x1d")
            echo "INACTIVE"
            ;;
        "0x1e")
            echo "req ready"
            ;;
        "0x1f")
            echo "req success"
            ;;
    esac
}

get_gpu_info ()
{
    ADDR="$1"
    REG="$2"
    CMD_1="$REG $3"
    REG_2="$4"

    READ_BYTE_LEN=0x00
    if [ $debug -eq 0 ]; then
        ${IPMI} ${RAW} ${BUS_NO} ${ADDR} ${READ_BYTE_LEN} ${CMD_1} > /dev/null 2>&1
        sleep 0.02
    else
        echo ${IPMI} ${RAW} ${BUS_NO} ${ADDR} ${READ_BYTE_LEN} ${CMD_1}
    fi

    READ_BYTE_LEN=0x05
    if [ $debug -eq 0 ]; then
        ret=`${IPMI} ${RAW} ${BUS_NO} ${ADDR} ${READ_BYTE_LEN} ${REG} | awk -F' ' '{ printf "0x"$5}'`
        if [[ $ret -eq 0x1f ]];then
            ret=`${IPMI} ${RAW} ${BUS_NO} ${ADDR} ${READ_BYTE_LEN} ${REG_2}`
            echo $ret
            return 1
        else
            echo $ret
        fi
    else
        echo ${IPMI} ${RAW} ${BUS_NO} ${ADDR} ${READ_BYTE_LEN} ${REG}
        echo ${IPMI} ${RAW} ${BUS_NO} ${ADDR} ${READ_BYTE_LEN} ${REG_2}
    fi
    return 0
}

I2C_NO=$1
[ -z "$I2C_NO" ] && echo "input bus no" && exit 1
BUS_NO=`printf "0x%02X" $(((I2C_NO - 1) * 2 + 1))`

#echo ${IPMI} ${RAW} ${BUS_NO}

CMD_ID_L="0x01 0x64"
CMD_ID_M="0x01 0x65"

GPU_ADDR_LIST="0x9E 0x9C 0x98 0x9A"

GPU_CODE_COMMAND="0x5C"
GPU_TEMP_CMD="0x04 0x02 0x00 0x00 0x80" GPU_CODE_DATA="0x5D"

GPU_CAPABILITY_0_CMD="0x04 0x01 0x00 0x00 0x80"
GPU_CAPABILITY_1_CMD="0x04 0x01 0x01 0x00 0x80"
GPU_POWER_CMD="0x04 0x04 0x00 0x00 0x80"

isfind=0
for gpu_addr in $GPU_ADDR_LIST
do
    if [ $debug -eq 1 ];then
        get_gpu_info ${gpu_addr} "${GPU_CODE_COMMAND}" "${GPU_TEMP_CMD}" "${GPU_CODE_DATA}"
        continue
    fi

    echo "${IPMI} ${RAW} ${BUS_NO} ${gpu_addr} ${CMD_ID_L}"
    ID_1=`${IPMI} ${RAW} ${BUS_NO} ${gpu_addr} ${CMD_ID_L}`
    echo "${IPMI} ${RAW} ${BUS_NO} ${gpu_addr} ${CMD_ID_M}"
    ID_2=`${IPMI} ${RAW} ${BUS_NO} ${gpu_addr} ${CMD_ID_M}`
    echo "ID: ${ID_2}${ID_1}"

    ret=`get_gpu_info ${gpu_addr} "${GPU_CODE_COMMAND}" "${GPU_TEMP_CMD}" "${GPU_CODE_DATA}"`
    if [ $? -eq 1 ]; then
        echo "########## $gpu_addr ##########"
        tmp=`echo $ret | awk -F' ' '{ printf "0x"$3 }'`
        printf "%-20s: %d 'C\n" "Temp" $tmp
        isfind=1
    else
        echo "err:" `to_err_msg $ret` "($ret)"
        continue
    fi

    ret=`get_gpu_info ${gpu_addr} "${GPU_CODE_COMMAND}" "${GPU_CAPABILITY_0_CMD}" "${GPU_CODE_DATA}"`
    if [ ! -z "$ret" ]; then
        printf "%-20s: %s\n" "Capability0" "$ret"
    fi

    ret=`get_gpu_info ${gpu_addr} "${GPU_CODE_COMMAND}" "${GPU_CAPABILITY_1_CMD}" "${GPU_CODE_DATA}"`
    if [ ! -z "$ret" ]; then
        printf "%-20s: %s\n" "Capability1" "$ret"
    fi

    ret=`get_gpu_info ${gpu_addr} "${GPU_CODE_COMMAND}" "${GPU_POWER_CMD}" "${GPU_CODE_DATA}"`
    if [ ! -z "$ret" ]; then
        printf "%-20s: %s\n" "Power" "$ret"
    fi

    is_serial=0
    SERIAL_NUM=""
    for (( i = 0; i < 4; i++ )); do
        pos=`printf "0x%02x" $i`
        GPU_SERIAL_NUM_CMD="0x04 0x05 0x02 ${pos} 0x80"
        ret=`get_gpu_info ${gpu_addr} "${GPU_CODE_COMMAND}" "${GPU_SERIAL_NUM_CMD}" "${GPU_CODE_DATA}"`
        if [ ! -z "$ret" ]; then
            is_serial=1
            #printf "%-20s: %s\n" "Power" "$ret"
            SERIAL_NUM="$SERIAL_NUM `echo $ret | awk -F' ' '{printf $2 $3 $4 $5}'`"
        fi
    done
    if [ $is_serial -eq 1 ]; then
        printf "%-20s: %s\n" "SerialNum" `comm_toString "$SERIAL_NUM"`
    fi

    if [ $isfind -eq 1]; then
        break;
    fi

    #READ_BYTE_LEN=0x00
    #${IPMI} ${RAW} ${BUS_NO} ${addr} ${READ_BYTE_LEN} ${GPU_SET_REG} ${GPU_TEMP_CMD} > /dev/null 2>&1
    #sleep 0.02
    #READ_BYTE_LEN=0x05
    #ret=`${IPMI} ${RAW} ${BUS_NO} ${addr} ${READ_BYTE_LEN} ${GPU_SET_REG} | awk -F' ' '{ printf "0x"$5}'`
    #if [[ $ret -eq 0x1f ]];then
    #    ret=`${IPMI} ${RAW} ${BUS_NO} ${addr} ${READ_BYTE_LEN} ${GPU_TEMP_REG} | awk -F' ' '{ printf "0x"$3}'`
    #    printf "%-20s: %d 'C\n" "Temp" $ret
    #fi
done






exit
#0xAC
SWITCH_ADDR=0xAC

READ_LEN=0x00
WRITE_DATA="0x10 0x12 0x01"
echo "# "${IPMI} ${RAW} ${BUS_NO} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW} ${BUS_NO} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}

GPU_ADDR=0x98
READ_LEN=0x00
WRITE_DATA="0x01 0x04 0x0F 0x01 0x66 0x5A"
echo "# "${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}

WRITE_DATA="0x03 0x83"
READ_LEN=0x05
echo "# "${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${WRITE_DATA}

GPU_ADDR=$SWITCH_ADDR
CMD_CMD=0x5C
CMD=0x05
CMD_V1=0x00
CMD_V2=0x80
#set cmd for vid
echo "## "${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${CMD_CMD} 0x04 ${CMD} ${TYPE} ${CMD_V1} ${CMD_V2}
${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${CMD_CMD} 0x04 ${CMD} ${TYPE} ${CMD_V1} ${CMD_V2}

#read cmd stat
#$IPMI ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${CMD_CMD}

READ_LEN=0x05
CMD_DATA=0x5D
echo "## "${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${CMD_DATA}
${IPMI} ${RAW} ${BUS_NO} ${GPU_ADDR} ${READ_LEN} ${CMD_DATA}

READ_LEN=0x00
WRITE_DATA="0x10 0x12 0x00"
echo "# "${IPMI} ${RAW} ${BUS_NO} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}
${IPMI} ${RAW} ${BUS_NO} ${SWITCH_ADDR} ${READ_LEN} ${WRITE_DATA}


