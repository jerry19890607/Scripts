#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW="raw 0x06 0x52"
I2C_CH=0x02
I2C_ADDR=`printf "0x%02x" $((I2C_CH * 2 + 1))`
MUX_ADDR=0xE2
#0x98 0x3e
MLP_ADDR=0x98
READ_LEN=0x01
WRITE_DATA=0x05

RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
echo ${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} ${WRITE_DATA}
sleep 0.5
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MUX_ADDR} ${READ_LEN} 2>&1`
echo "Set MUX to: " $RET

WRITE_DATA="0x01"
READ_LEN=0x01
COUNT=195
ADDRS=""
TEMPS=""

echo ${IPMI} ${RAW} ${I2C_ADDR} ${MLP_ADDR} ${READ_LEN} ${WRITE_DATA}
RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MLP_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
if [ $? -ne 0 ];then
    MLP_ADDR=0x3e
    echo ${IPMI} ${RAW} ${I2C_ADDR} ${MLP_ADDR} ${READ_LEN} ${WRITE_DATA}
    RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MLP_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    echo $RET
    exit
fi
echo $RET
exit

while [ 1 ]
do
    MLP_ADDR=`printf "0x%02x" $COUNT`
    printf "%s\r" $MLP_ADDR
    RET=`${IPMI} ${RAW} ${I2C_ADDR} ${MLP_ADDR} ${READ_LEN} ${WRITE_DATA} 2>&1`
    if [ $? -eq 0 ]; then
        ADDRS=$ADDRS" "$MLP_ADDR
        TEMPS=$TEMPS" "$RET
        #echo ""
        #echo ${IPMI} ${RAW} ${I2C_ADDR} ${MLP_ADDR} ${READ_LEN} ${WRITE_DATA}
        #echo "read:" $RET
    fi
    [ $COUNT -eq 256 ] && echo "done" && break
    COUNT=$((COUNT+1))
    sleep 0.5
done
echo $ADDRS
echo $TEMPS
