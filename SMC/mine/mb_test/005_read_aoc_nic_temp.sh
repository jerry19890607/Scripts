#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

I2C_NO=$1
BUS_NO=`printf "0x%02X" $(((I2C_NO - 1) * 2 + 1))`
[ -z "$I2C_NO" ] && echo "$0 [I2C_NO]" && exit 1


CMD="0x06 0x52"
NIC_ADDR="0xc2"

ARP="0x01"
PREPARE="0x00 0x01"
RESET="0x00 0x02"

GET_INFO="0x11 0x03"
SET_ADDR="0x00 0x04"

GET_SERIAL_NUM="0x3D"
GET_MODEL_NAME="0x20"

ASSIGN_ADDR="0x40"
if [ ! -z "$2" ];then
    ASSIGN_ADDR=$2
fi

echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${ARP}
RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${ARP}`
if [ $? -eq 0 ]; then
    echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${PREPARE}
    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${PREPARE}`

    #echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${RESET}
    #RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${RESET}`

    echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${GET_INFO}
    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${GET_INFO}`
    if [ $? -eq 0 ]; then
        #echo $RET
        data=""
        idx=0
        VENDOR_ID=""
        DEV_ID=""

        for val in $RET
        do
            case $idx in
                3|4)
                    VENDOR_ID="${val}${VENDOR_ID}"
                    ;;
                5|6)
                    DEV_ID="${val}${DEV_ID}"
                    ;;
            esac
            data="${data} 0x${val}"
            idx=$((idx + 1))
        done

        #echo VENDOR: 0x${VENDOR_ID}
        #echo DEVICE: 0x${DEV_ID}

        echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${SET_ADDR} ${data} ${ASSIGN_ADDR}
        RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${SET_ADDR} ${data} ${ASSIGN_ADDR}`
        if [ $? -ne 0 ]; then
            echo "assign address failed"
            exit 1
        fi

        echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${GET_INFO}
        RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NIC_ADDR} ${GET_INFO} 2>&1`
        if [ $? -eq 0 ]; then
            echo $RET
        fi

        READ=0x01
        SERIAL_NUM=""
        MODEL=""
        for (( i = 0; i < 24; i++ )); do
            if [ $i -lt 12 ];then
                ADDRESS=`printf "0x%02x" $((GET_SERIAL_NUM + i))`
                #echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ASSIGN_ADDR} ${READ} ${ADDRESS}
                RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ASSIGN_ADDR} ${READ} ${ADDRESS} `
                RET=`comm_toString $RET`
                SERIAL_NUM="${SERIAL_NUM}${RET}"
            fi

            ADDRESS=`printf "0x%02x" $((GET_MODEL_NAME + i))`
            RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ASSIGN_ADDR} ${READ} ${ADDRESS} `
            if [ $RET != "ff" ];then
                RET=`comm_toString $RET`
                MODEL="${MODEL}${RET}"
            fi
        done
    fi

    READ="0x01"
    WRITE="0x0A"
    echo ${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ASSIGN_ADDR} ${READ} ${WRITE}
    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ASSIGN_ADDR} ${READ} ${WRITE}`
    Temp=`comm_getValueByIndex "$RET" 1`

    printf "%-15s: %s\n" "MODEL:" ${MODEL}
    printf "%-15s: %s\n" "SERIAL:" ${SERIAL_NUM}
    printf "%-15s: %d \`C\n"    "Temp"         0x${Temp}
fi
