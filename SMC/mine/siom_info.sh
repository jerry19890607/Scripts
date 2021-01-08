#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x06 0x52"
# BMC ----- I2C ch0
#      +--- I2C ch1
#      +--- I2C ch2 ----- MUX 0
#      .              +-- MUX 1
#      .              +-- MUX 2 ----- M.2 slot 0
#      .              .           +-- M.2 slot 1
#      .              .           +-- M.2 slot 2
#      .              .           +-- M.2 slot 3
I2C_CH=0x02
I2C_ADDR=`printf "0x%02x" $((I2C_CH * 2 + 1))`

MUX_ADDR=$1
CH=$2
[ -z "$MUX_ADDR" ] && echo "input set mux addr" && exit 1
[ -z "$CH" ] && echo "input set mux ch" && exit 1

READ_LEN=0x01
WRITE_DATA=`printf "0x%02x" $((1 << CH))`
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
#echo $RET
echo ${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA}
sleep 2
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} 2>&1`
if [ $? -eq 0 ];then
    echo "set MUX to:" $RET "Success"
else
    echo "set MUX fail"
    exit
fi

ZL8800_SLAVE_ADDR=0x50
READ_LEN=0x00
WRITE_DATA="0x8E 0x00 0x00"
IS_FAIL=0
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${ZL8800_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
if [ $? -eq 0 ];then
    READ_LEN=0x02
    WRITE_DATA=0x8E
    RET=`${IPMI} ${RAW} ${I2C_ADDR} ${ZL8800_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ];then
        echo "OMNI:" $RET
    else
        IS_FAIL=1
    fi
else
    IS_FAIL=1
fi


ASSIGNED_ADDR=0x40
READ_LEN=0x01

if [ $IS_FAIL -eq 1 ]; then
    IS_FAIL=1
    for (( i = 0; i < 6; i++ )); do
        WRITE_DATA=`printf "0x%02x" $((10 + i))`
        RET=`${IPMI} ${RAW} ${I2C_ADDR} ${ASSIGNED_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
        if [ $? -eq 0 ];then
            val=`printf "0x%s" $RET`
            printf "%d\n" $val
            IS_FAIL=0
        fi
    done
fi

if [ $IS_FAIL -eq 1 ]; then
    IB_SLAVE_ADDR=0x60
    READ_LEN=0x00
    WRITE_DATA="0xCB 0x01 0x01"
    RET=`${IPMI} ${RAW} ${I2C_ADDR} ${IB_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`

    READ_LEN=0x07
    WRITE_DATA="0xDB"
    RET=`${IPMI} ${RAW} ${I2C_ADDR} ${IB_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ];then
        echo "IB:" $RET
        IS_FAIL=0
    fi
fi

if [ $IS_FAIL -eq 1 ]; then
    NCT6683_ADDR=0xC2
    READ_LEN=0x12
    WRITE_DATE=0x03
    RET=`${IPMI} ${RAW} ${I2C_ADDR} ${NCT6683_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ];then
        echo "NCT:" $RET
        IS_FAIL=0
    else
        echo "all fail"
    fi

fi
