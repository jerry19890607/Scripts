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
[ -z "$MUX_ADDR" ] && echo "input set mux addr" && exit 1

#sample: X11SPA-TF
#M.2
#8 4 2 1   8 4 2 1
#7 6 5 4 | 3 2 1 0  | channel bit
#- - - - | x x x x  | slot 
SET_MUX_CH=$2
[ -z "$SET_MUX_CH" ] && echo "input set mux ch to" && exit 1

READ_LEN=0x00
WRITE_DATA="${SET_MUX_CH}"

echo ${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA}
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
#echo $RET

READ_LEN=0x01
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} 2>&1`
if [ $? -eq 0 ];then
    echo "set MUX to:" $RET
else
    echo "set MUX fail"
    exit
fi

# Normal 0xd4
M2_ADDRS=0xd4
READ_LEN=0x24

WRITE_DATA="0x0"

printf "%s\r" "${IPMI} ${RAW} ${I2C_ADDR} ${M2_ADDRS} ${READ_LEN} ${WRITE_DATA}"
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${M2_ADDRS} ${READ_LEN} ${WRITE_DATA} 2>&1`
if [ $? -eq 0 ];then
    echo ""
    echo $RET
    Temp=`comm_getValueByIndex "$RET" 3`
    VID_h=`comm_getValueByIndex "$RET" 9`
    VID_l=`comm_getValueByIndex "$RET" 10`
    SERIAL_NUM=`comm_getValueByRange "$RET" 11 20`
    SERIAL_NUM=`comm_toString "${SERIAL_NUM}"`

    printf "%-15s: %d \`C\n"    "Temp"         0x${Temp}
    printf "%-15s: %s \n"       "VendorID"     "${VID_h}${VID_l}"
    printf "%-15s: %s \n"       "SerialNum"    ${SERIAL_NUM}
else
    echo ""
    #echo $RET
    echo "fail"
fi
