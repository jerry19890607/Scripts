#!/bin/bash
COMMON=common.sh
[ ! -f $COMMON ] && echo "$COMMON don't exist" && exit 1
. $COMMON $@

RAW_CMD="raw 0x06 0x52"

#3 or 6
ID="$1"
[ -z "$ID" ] && ID=6
BUS=`printf "0x%02X" $((ID * 2 + 1))`
CMD="0x66 0x01"
INDEX="0x06"

function getVPDdata
{
    echo "=============================================="
    echo "NVMe Slot:" $1
    CHG_MUX_CMD="0x60 0x00"
    GET_VPD_CMD="0xA6 0x5C 0x00"
    SLOT=$1
    REG_SLOT_BASE="0x40"
    REG_SLOT=`printf "0x%02x" $((REG_SLOT_BASE + SLOT))`
    ${IPMI} ${RAW_CMD} ${BUS} ${SLAVE_ADDR} ${CHG_MUX_CMD} ${REG_SLOT} > /dev/null
    echo ${IPMI} ${RAW_CMD} ${BUS} ${SLAVE_ADDR} ${CHG_MUX_CMD} ${REG_SLOT}
    echo ${IPMI} ${RAW_CMD} ${BUS} ${SLAVE_ADDR} ${GET_VPD_CMD}
    datas=`${IPMI} ${RAW_CMD} ${BUS} ${SLAVE_ADDR} ${GET_VPD_CMD}`
    echo $datas

    cnt=0
    CLASS_CODE=""
    VENDOR_ID=""
    SERIAL_NUM=""
    MODEL_NUM=""
    PORT_0_MAX_LINK_SPEED=""
    PORT_0_MAX_LINK_WIDTH=""
    PORT_1_MAX_LINK_SPEED=""
    PORT_1_MAX_LINK_WIDTH=""
    INIT_POWER_CAPABILITIES=""
    MAX_POWER_CAPABILITIES=""
    for data in $datas
    do
        case $cnt in
            [0-2])
                CLASS_CODE="$CLASS_CODE $data"
                ;;
            [3-4])
                VENDOR_ID="$VENDOR_ID $data"
                ;;
            [5-9] | 1[0-9] | 2[0-5])
                SERIAL_NUM="$SERIAL_NUM $data"
                ;;
            2[6-9] | [3-5][0-9] | 6[0-4])
                MODEL_NUM="$MODEL_NUM $data"
                ;;
            65)
                PORT_0_MAX_LINK_SPEED=$data
                ;;
            66)
                PORT_0_MAX_LINK_WIDTH=$data
                ;;
            67)
                PORT_1_MAX_LINK_SPEED=$data
                ;;
            68)
                PORT_1_MAX_LINK_WIDTH=$data
                ;;
            69)
                INIT_POWER_CAPABILITIES=$data
                ;;
            72)
                MAX_POWER_CAPABILITIES=$data
                ;;
        esac
        cnt=$((cnt + 1))
        #echo 0x$data | xxd -r
        #printf "%c " "0x$data"
    done
    STR_SERIAL_NUM=`comm_toString "$SERIAL_NUM"`
    STR_MODEL_NUM=`comm_toString "$MODEL_NUM"`

    printf "%-20s%s\n" "ClassCode:" "$CLASS_CODE"
    printf "%-20s%s\n" "VendorId:" "$VENDOR_ID"

    printf "%-20s%s\n" "Hex SerialNum:" "$SERIAL_NUM"
    printf "%-20s%s\n" "SerialNum:" "$STR_SERIAL_NUM"

    printf "%-20s%s\n" "Hex ModelNum:" "$MODEL_NUM"
    printf "%-20s%s\n" "ModelNum:" "$STR_MODEL_NUM"

    printf "%-20s%s\n" "Port0MaxLinkSpeed:" "$PORT_0_MAX_LINK_SPEED"
    printf "%-20s%s\n" "Port0MaxLinkWidth:" "$PORT_0_MAX_LINK_WIDTH"
    printf "%-20s%s\n" "Port1MaxLinkSpeed:" "$PORT_1_MAX_LINK_SPEED"
    printf "%-20s%s\n" "Port1MaxLinkWidth:" "$PORT_1_MAX_LINK_WIDTH"
    printf "%-20s%s\n" "InitialPowerReq:" "$INIT_POWER_CAPABILITIES"
    printf "%-20s%s\n" "MaxPowerReq:" "$MAX_POWER_CAPABILITIES"
}

#function getD4data
#{
#
#}

#echo "-> ${IPMI} ${RAW_CMD} ${BUS} ${CMD}"
echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${INDEX}"
BPN_TYPE=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${INDEX}`

FORMAT_CMD="0x03 0x70 0x1 0x20"
echo "> ${IPMI} ${RAW_CMD} ${FORMAT_CMD}"
BPN_FORMAT=`${IPMI} ${RAW_CMD} ${FORMAT_CMD}`

echo "BPN Type: $BPN_TYPE, FORMAT: $BPN_FORMAT"
echo "----------------------------------------"
case "$BPN_TYPE" in
    *"55"* | *"57"*)
        echo "Gen 2."
        HIGH_ID_REG="0x05"
        LOW_ID_REG="0x04"
        CPLD_REV_REG="0x07"

        PRESENT_MAPS_1="0x10"
        PRESENT_MAPS_2="0x11"
        SAVE_RM_MAPS_1="0x18"
        SAVE_RM_MAPS_2="0x19"
        ;;
    *"56"* | *"58"*)
        echo "Gen 2."
        HIGH_ID_REG="0x05"
        LOW_ID_REG="0x04"
        CPLD_REV_REG="0x07"
        DAY_REG="0x90"
        MONTH_REG="0x91"
        YEAR_REG="0x92"

        PRESENT_MAPS_1="0x10"
        PRESENT_MAPS_2="0x11"
        SAVE_RM_MAPS_1="0x18"
        SAVE_RM_MAPS_2="0x19"
        ;;
    *)
        echo "Gen 1."
        HIGH_ID_REG="0x07"
        CPLD_REV_REG="0x06"

        PRESENT_MAPS_1="0x00"
        PRESENT_MAPS_2="0x01"
        SAVE_RM_MAPS_1="0x02"
        SAVE_RM_MAPS_2="0x03"
        ;;
esac

if [ ! -z "$HIGH_ID_REG" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${HIGH_ID_REG}"
    HIGH_ID=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${HIGH_ID_REG}`
fi

if [ ! -z "$LOW_ID_REG" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${LOW_ID_REG}"
    LOW_ID=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${LOW_ID_REG}`
fi

if [ ! -z "$CPLD_REV_REG" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${CPLD_REV_REG}"
    REV=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${CPLD_REV_REG}`
fi

if [ ! -z "$DAY_REG" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${DAY_REG}"
    day=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${DAY_REG}`
fi

if [ ! -z "$MONTH_REG" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${MONTH_REG}"
    mon=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${MONTH_REG}`
fi

if [ ! -z "$YEAR_REG" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${YEAR_REG}"
    year=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${YEAR_REG}`
fi

if [ ! -z "$PRESENT_MAPS_1" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${PRESENT_MAPS_1}"
    present_1=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${PRESENT_MAPS_1}`
fi

if [ ! -z "$PRESENT_MAPS_2" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${PRESENT_MAPS_2}"
    present_2=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${PRESENT_MAPS_2}`
fi

if [ ! -z "$SAVE_RM_MAPS_1" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${SAVE_RM_MAPS_1}"
    save_rm_1=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${SAVE_RM_MAPS_1}`
fi

if [ ! -z "$SAVE_RM_MAPS_2" ];then
    echo "> ${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${SAVE_RM_MAPS_2}"
    save_rm_2=`${IPMI} ${RAW_CMD} ${BUS} ${CMD} ${SAVE_RM_MAPS_2}`
fi

if [ ! -z "$REV" ];then
    echo "BPN Rev:$REV"
fi

FW_VER_ID="${HIGH_ID}${LOW_ID}"
if [ ! -z "$FW_VER_ID" ];then
    echo "fwVerID:$FW_VER_ID"
fi

FW_VER_DC="${year}${mon}${day}"
if [ ! -z "$FW_VER_DC" ];then
    echo "fwVerDC:$FW_VER_DC"
fi

PRESENT_MAP="${present_2}${present_1}"
if [ ! -z "$PRESENT_MAP" ];then
    echo "PresentMaps:$PRESENT_MAP"
    val_hex=`printf "0x%s%s" ${present_2} ${present_1}`
fi

SAVE_RM_MAP="${save_rm_2}${save_rm_1}"
if [ ! -z "$SAVE_RM_MAP" ];then
    echo "SaveRmMaps:$SAVE_RM_MAP"
fi

val=`printf "%d" $val_hex`
if [[ $val != 0 ]]; then
    for (( i = 0; i < 32; i++ )); do
        isPresent=$(((val >> i) & 0x01))
        if [ $isPresent -eq 1 ];then
            #echo $i
            getVPDdata $i
        fi
    done
fi
echo "=============================================="
