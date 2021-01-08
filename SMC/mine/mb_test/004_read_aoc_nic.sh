#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

I2C_NO=$1
BUS_NO=`printf "0x%02X" $(((I2C_NO - 1) * 2 + 1))`
[ -z "$I2C_NO" ] && echo "$0 [I2C_NO]" && exit 1

CMD="0x06 0x52"
IS_SUCCESS=0

ZL8800_SLAVE_ADDR=0x50
READ_LEN=0x00
WRITE_DATA="0x8E 0x00 0x00"
RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ZL8800_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
if [ $? -eq 0 ];then
    READ_LEN=0x02
    WRITE_DATA=0x8E
    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ZL8800_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ];then
        echo "OMNI:" $RET
        IS_SUCCESS=1
    fi
fi

if [ $IS_SUCCESS -eq 0 ]; then
    ASSIGNED_ADDR=0x40
    READ_LEN=0x01

    for (( i = 0; i < 6; i++ )); do
        WRITE_DATA=`printf "0x%02x" $((10 + i))`
        RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${ASSIGNED_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
        if [ $? -eq 0 ];then
            val=`printf "0x%s" $RET`
            printf "%d\n" $val
            IS_SUCCESS=1
        fi
    done
fi

if [ $IS_SUCCESS -eq 0 ]; then
    IB_SLAVE_ADDR=0x60
    READ_LEN=0x00
    WRITE_DATA="0xCB 0x01 0x01"
    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${IB_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`

    READ_LEN=0x07
    WRITE_DATA="0xDB"
    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${IB_SLAVE_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ];then
        echo "IB:" $RET
        IS_SUCCESS=1
    fi
fi

if [ $IS_SUCCESS -eq 0 ]; then
    NCT6683_ADDR=0xC2
    READ_LEN=0x12
    WRITE_DATE=0x03

    RET=`${IPMI} ${RAW} ${CMD} ${BUS_NO} ${NCT6683_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ];then
        echo "NCT:" $RET
        IS_SUCCESS=1
    else
        echo "all fail"
    fi
fi
