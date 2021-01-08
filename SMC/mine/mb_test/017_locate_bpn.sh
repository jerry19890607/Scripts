#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW_CMD="raw 0x06 0x52"

#3 or 6
ID="$1"
[ -z "$ID" ] && ID=6
BUS=`printf "0x%02X" $((ID * 2 + 1))`

NVME_ADDR="0x66"
TYPE="0x06"

#NVME_LOCATE_REG="0x50"
NVME_LOCATE_REG="0x30"
NVME_LOCATE_BUTTON="0x05"
NVME_LOCATE_STOP="0x00"

READ_LEN=0x01
CMD="$NVME_ADDR $READ_LEN"

slot=$2
[ -z "$slot" ] && slot=0

blink=`printf "0x%02x" $3`
[ -z "$blink" ] && blink=0x00

#echo "-> ${IPMI} ${RAW_CMD} ${BUS} ${CMD}"
echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${TYPE}"
BPN_TYPE=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${TYPE}`

FORMAT_CMD="0x03 0x70 0x1 0x20"
echo "> ${IPMI} ${RAW_CMD} ${FORMAT_CMD}"
BPN_FORMAT=`${IPMI} ${RAW_CMD} ${FORMAT_CMD}`

echo "BPN Type: $BPN_TYPE, FORMAT: $BPN_FORMAT"

case "$BPN_TYPE" in
    *"55"* | *"57"*)
        echo "Gen 2."
        HIGH_ID_REG="0x05"
        LOW_ID_REG="0x04"
        CPLD_REV_REG="0x07"

        PRESENT_MAPS="0x10 0x11 0x12 0x13"
        SAVE_RM_MAPS="0x18 0x19 0x1A 0x1B"

        NVME_LOCATE_REG="0x30"
        ;;
    *"56"* | *"58"*)
        echo "Gen 2."
        HIGH_ID_REG="0x05"
        LOW_ID_REG="0x04"
        CPLD_REV_REG="0x07"

        DAY_REG="0x90"
        MONTH_REG="0x91"
        YEAR_REG="0x92"

        PRESENT_MAPS="0x10 0x11 0x12 0x13"
        SAVE_RM_MAPS="0x18 0x19 0x1A 0x1B"

        NVME_LOCATE_REG="0x30"
        ;;
    *)
        echo "Gen 1."
        HIGH_ID_REG="0x07"
        CPLD_REV_REG="0x06"

        PRESENT_MAPS="0x00 0x01"
        SAVE_RM_MAPS="0x02 0x03"
        ;;
esac

READ_LEN=0x00
CMD="$NVME_ADDR $READ_LEN"

INDEX=`printf "0x%02X" $((slot + NVME_LOCATE_REG))`

echo ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${INDEX} ${blink}
${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${INDEX} ${blink}

#*** Set NVMe SSD locate/dislocate (Blink/Unblink)
#"[Gen1] ipmitool -H $IP -U ADMIN -P ADMIN raw 0x06 0x52 0x05 0x66 0x00 0x50+slot 0x01/0x00
#0x50 NVME_REG_LOCATE + slot

#0x01/0x00 NVME_LOCATE_SET / NVME_LOCATE_STOP
#[Gen2] ipmitool -H $IP -U ADMIN -P ADMIN raw 0x06 0x52 0x05 0x66 0x00 0x30+slot 0x01/0x00

#0x30 NVME_REG_LOCATE + slot
#0x01/0x00 NVME_LOCATE_SET / NVME_LOCATE_STOP"
