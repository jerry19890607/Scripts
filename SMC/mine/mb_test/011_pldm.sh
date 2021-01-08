# [4] PLDM over MCTP over SMbus for getting sendor reading "sensorID = 0x3",
# ipmitool -I lanplus -H $IP -U ADMIN -P ADMIN raw 
# Format: 0x30 0x70 0xd4 [smbus] [MCTP msg_type] [read_len] [pldm hdr] [pldm type] [cmdcode] [sensor ID,2byte][rearmEventState]
#         0x30 0x70 0xd4 0xc0    0x01            0x20       0x80       0x02        0x11      0x03 0x00        0x00
# intel 0xc0                                                                                 0x0000 ~ 0xffff

#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW_CMD="raw 0x30 0x70 0xD4"
#SMBUS="0XCE"
SMBUS="0X64"
MCTP_CMD="0x01 0x20 0x80 0x02 0x11"
STAT="0x00"

END=`printf "%d" 0xffff`
for (( i = 0; i <= $END; i++ )); do
    #statements
    SENSOR_ID=`printf "0x%02x 0x%02x\n" $((i % 256)) $((i / 256))`

    ret=`$IPMI ${RAW_CMD} ${SMBUS} ${MCTP_CMD} ${SENSOR_ID} ${STAT}`
    [ $? -ne 0 ] && continue

    printf "$IPMI ${RAW_CMD} ${SMBUS} ${MCTP_CMD} ${SENSOR_ID} ${STAT}\n"
    #echo ""
    completion_code=`echo $ret | awk -F ' ' '{printf $4}'`
    sensor_operation_state=`echo $ret | awk -F ' ' '{printf $6}'`
    reading=`echo $ret | awk -F ' ' '{printf $11}'`
    echo "ccode: $completion_code"
    if [ $completion_code -eq 0 ]; then
        if [ $sensor_operation_state -eq 0 ]; then
            echo ""
            echo $ret
            echo "sensorID ${SENSOR_ID}, temperature: $reading"
            break;
        fi
    fi
    #echo $completion_code
    #echo $sensor_operation_state
    #echo $reading
    sleep 0.5
done

