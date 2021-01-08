#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

usage ()
{
    echo "Please input $0 [Assert: 0:de-assert, 1:assert] [Sensor Type] [Sensor Number] [Event Type] [Data 1] [Data 2] [Data 3]"
    echo "error: ($1)"

    echo "Sensor Type"
    echo "0x05: configuration error <= Processor    # OEM_DATA_1 <= offset"
    echo "0xcc: OEM MemoryErr       <= Memory       # OEM_DATA_1 <= offset"
}

RAW="raw 0x0a 0x44"

ENABLE=$1

OEM_DATA_1=0xff
OEM_DATA_2=0xff
OEM_DATA_3=0xff

SENSOR_TYPE=$2
#SENSOR_NO="0x00"
SENSOR_NO=$3
EVENT_DIR_TYPE=$4

if [ ! -z "$5" ]; then
    OEM_DATA_1=$5
fi

if [ ! -z "$6" ]; then
    OEM_DATA_2=$6
fi

if [ ! -z "$7" ]; then
    OEM_DATA_3=$7
fi

RECORD_ID="0x05 0x00"
RECORD_TYPE="0x02"
TIMESTAMP="0x44 0xB4 0x90 0x5C"
GENERATOR_ID="0x21 0x00"
EVM_REV="0x04"

[ -z "$ENABLE" ] && usage "assert status" && exit 1
[ -z "$SENSOR_TYPE" ] && usage "sensor type" && exit 1
[ -z "$SENSOR_NO" ] && usage "sensor number" && exit 1
[ -z "$EVENT_DIR_TYPE" ] && usage "event type" && exit 1

#EVENT_DIR_TYPE="0x6F"
if [ $ENABLE -ne 1 ];then
    EVENT_DIR_TYPE=`printf "0x%02x" $((EVENT_DIR_TYPE | (1<<7)))`
fi

[ -z "$SENSOR_TYPE" ] && usage "error: senser type" && exit 1
[ -z "$OEM_DATA_1" ] || [ -z "$OEM_DATA_2" ] || [ -z "$OEM_DATA_3" ] && usage "error: oem data" && exit 1

#00 00 02 00 00 00 00 04 00 04 07 ff 6f 05 ff ff
DATA="${RECORD_ID} ${RECORD_TYPE} ${TIMESTAMP} ${GENERATOR_ID} ${EVM_REV} \
     ${SENSOR_TYPE} ${SENSOR_NO} ${EVENT_DIR_TYPE} \
     ${OEM_DATA_1} ${OEM_DATA_2} ${OEM_DATA_3}"
echo ${IPMI} ${RAW} ${DATA}
${IPMI} ${RAW} ${DATA}
#${IPMI} ${RAW} 00 00 02 00 00 00 00 04 00 04 07 0xff 0x6f 05 0xff 0xff
