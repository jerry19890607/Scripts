#!/bin/bash

#IP="10.138.160.142"
IP="10.138.160.76"

REG_GPIO_BASE="1E78"
REG_GPIO_DATAVALUE_OFFSET=("0000" "0020" "0070" "0078" "0080" "0088" "01E0" "01E8")
REG_GPIO_DIRECTION_OFFSET=("0004" "0024" "0074" "007C" "0084" "008C" "01E4" "01EC")
REG_GPIO_INT_EN_OFFSET=("0008" "0028" "0098" "00E8" "0118" "0148" "0178" "01A8")
REG_GPIO_INT_SENSTYPE_0_OFFSET=("000C" "002C" "009C" "00EC" "011C" "014C" "017C" "01AC")
REG_GPIO_INT_SENSTYPE_1_OFFSET=("0010" "0030" "00A0" "00F0" "0120" "0150" "0180" "01B0")
REG_GPIO_INT_SENSTYPE_2_OFFSET=("0014" "0034" "00A4" "00F4" "0124" "0154" "0184" "01B4")

REG_GPIO_MULTI_FUNC_CONTROL=(
"SCU80:0:1"            ""
"SCU80:1:1"            ""
"SCU80:15:1"           "SCU80:2:1"
""                     "SCU80:3:1"
"SCU90:22:1,SCU90:6:0" "SCU80:4:1,SCU90:6:0"
)

REG_GPIO_MULTI_FUNC_NAME=(
"MAC1LINK" ""
"MAC2LINK" ""
"SPI1CS1#" "TIMER3"
""         "TIMER4"
"SCL9"     "TIMER5"
"SDA9"     "TIMER6"
)

get_rawdata_bits()
{
    RAWDATA=`echo ${RAWDATA} | cut -d ' ' -f $1`
    RAWDATA2BIN=`echo "ibase=16; obase=2;" ${RAWDATA^^} | bc`
    RAWDATA2BIN_DSP=`printf "%8s\n" ${RAWDATA2BIN}|tr ' ' '0'`

    echo -n "> "
    for i in {1..8}
    do
        BIT=`echo $(($i-8))`
        BIT=`echo ${BIT#-}`
        temp=`echo "${RAWDATA2BIN_DSP:$(($i-1)):1}"`
        if [ ${BIT} -eq ${GPIO_NUM} ]; then
            RES=${temp}
            echo -e -n "\033[31m${temp}\033[0m"
        else
            echo -n "${temp}"
        fi
    done

    return ${RES}
}

get_rawdata_bytes()
{
    CMD=$1
    echo ${CMD}
    RAWDATA=`${CMD}`

    echo -n "> "
    for i in {1..4}
    do
        temp=`echo ${RAWDATA} | cut -d ' ' -f $i`
        if [ $((${DATA_BYTE}+$i)) -eq 4 ]; then
            RAWDATABYTE=$i
            echo -e -n "\033[31m${temp}\033[0m "
        else
            echo -n "${temp} "
        fi
    done
    echo

    get_rawdata_bits "${RAWDATABYTE}"
    return $?
}

check_multi_func()
{
    MAP_INDEX=$(((${GPIO_CHAR_NUM}*8)+${GPIO_NUM}))
    echo ${MAP_INDEX}
    MAP_INDEX=$((${MAP_INDEX}*2))
    echo ${MAP_INDEX}

    TEMP_STR=${REG_GPIO_MULTI_FUNC_CONTROL[${MAP_INDEX}]}
    echo "M_FUN_REG1: ${REG_GPIO_MULTI_FUNC_CONTROL[${MAP_INDEX}]}, M_FUN_REG2: ${REG_GPIO_MULTI_FUNC_CONTROL[$((${MAP_INDEX}+1))]}"
    echo "M_FUN_NAME1: ${REG_GPIO_MULTI_FUNC_NAME[${MAP_INDEX}]}, M_FUN_NAME2: ${REG_GPIO_MULTI_FUNC_NAME[$((${MAP_INDEX}+1))]}"
}

if [ $1 ]; then IP=$1; fi

echo -n "Please input the name of the pin you want to query: "
read input; echo

GPIO_GROUP=`echo ${input:${#input}-2:1}`
GPIO_GROUP_CHAR=`echo ${GPIO_GROUP^^}`
GPIO_GROUP_NUM=`echo -n ${GPIO_GROUP_CHAR:0:1} | od -An -tuC`

if [ ${#input} -gt 2 ]; then
    input=`echo ${input^^}`
    GPIO_GROUP_NUM=$((${GPIO_GROUP_NUM}+26))
    GPIO_GROUP_CHAR="${input:0:1}${GPIO_GROUP_CHAR}"
fi

DATA_BYTE=$(((${GPIO_GROUP_NUM}-65)%4))
GPIO_CHAR_NUM=$((${GPIO_GROUP_NUM}-65))
GPIO_GROUP_NUM=$(((${GPIO_GROUP_NUM}-65)/4))
GPIO_NUM=`echo ${input:${#input}-1:1}`

#check_multi_func
#exit 0

#------ Data Value Register ------#
GPIO_NAME="\033[33mGPIO${GPIO_GROUP_CHAR}${GPIO_NUM}\033[0m"
GPIO_ADDR="0x${REG_GPIO_BASE}${REG_GPIO_DATAVALUE_OFFSET[$GPIO_GROUP_NUM]}"
GPIO_DESC="\033[33mDATA Value\033[0m"
echo -e "*** Get ${GPIO_NAME} raw data from ${GPIO_DESC} Register (${GPIO_ADDR}) ***"

OFFSET=`echo ${REG_GPIO_DATAVALUE_OFFSET[${GPIO_GROUP_NUM}]%%:*}`
OFFSET=`echo 0x${OFFSET:0:2} 0x${OFFSET:2:2}`
BASEADDR=`echo 0x${REG_GPIO_BASE:0:2} 0x${REG_GPIO_BASE:2:2}`

CMD="ipmitool -H ${IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 ${BASEADDR} ${OFFSET}"
get_rawdata_bytes "${CMD}"
if [ $? -eq 1 ]; then
    echo -e -n " -----> \033[31mhigh\033[0m(bit${GPIO_NUM})\n\n"
else
    echo -e -n " -----> \033[31mlow\033[0m(bit${GPIO_NUM})\n\n"
fi

#------ Direction Register ------#
GPIO_NAME="GPIO${GPIO_GROUP_CHAR}${GPIO_NUM}"
GPIO_ADDR="0x${REG_GPIO_BASE}${REG_GPIO_DIRECTION_OFFSET[$GPIO_GROUP_NUM]}"
GPIO_DESC="\033[33mDirection\033[0m"
echo -e "*** Get ${GPIO_NAME} raw data from ${GPIO_DESC} Register (${GPIO_ADDR}) ***"

OFFSET=`echo ${REG_GPIO_DIRECTION_OFFSET[${GPIO_GROUP_NUM}]%%:*}`
OFFSET=`echo 0x${OFFSET:0:2} 0x${OFFSET:2:2}`
BASEADDR=`echo 0x${REG_GPIO_BASE:0:2} 0x${REG_GPIO_BASE:2:2}`

CMD="ipmitool -H ${IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 ${BASEADDR} ${OFFSET}"
get_rawdata_bytes "${CMD}"
if [ $? -eq 1 ]; then
    echo -e -n " -----> \033[31moutput\033[0m(bit${GPIO_NUM})\n\n"
    exit 0
else
    echo -e -n " -----> \033[31minput\033[0m(bit${GPIO_NUM})\n\n"
fi

#------ Interrupt Enable Register ------#
GPIO_NAME="GPIO${GPIO_GROUP_CHAR}${GPIO_NUM}"
GPIO_ADDR="0x${REG_GPIO_BASE}${REG_GPIO_INT_EN_OFFSET[$GPIO_GROUP_NUM]}"
GPIO_DESC="\033[33mInterrupt Enable\033[0m"
echo -e "*** Get ${GPIO_NAME} raw data from ${GPIO_DESC} Register (${GPIO_ADDR}) ***"

OFFSET=`echo ${REG_GPIO_INT_EN_OFFSET[${GPIO_GROUP_NUM}]%%:*}`
OFFSET=`echo 0x${OFFSET:0:2} 0x${OFFSET:2:2}`
BASEADDR=`echo 0x${REG_GPIO_BASE:0:2} 0x${REG_GPIO_BASE:2:2}`

CMD="ipmitool -H ${IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 ${BASEADDR} ${OFFSET}"
get_rawdata_bytes "${CMD}"
if [ $? -eq 1 ]; then
    echo -e -n " -----> \033[31minterrupt enable\033[0m(bit${GPIO_NUM})\n\n"
else
    echo -e -n " -----> \033[31minterrupt disable\033[0m(bit${GPIO_NUM})\n\n"
    exit 0
fi

#------ Interrupt Sensitivity Type 0 Register ------#
GPIO_NAME="GPIO${GPIO_GROUP_CHAR}${GPIO_NUM}"
GPIO_ADDR="0x${REG_GPIO_BASE}${REG_GPIO_INT_SENSTYPE_0_OFFSET[$GPIO_GROUP_NUM]}"
GPIO_DESC="\033[33mInterrupt Sensitivity Type 0\033[0m"
echo -e "*** Get ${GPIO_NAME} raw data from ${GPIO_DESC} Register (${GPIO_ADDR}) ***"

OFFSET=`echo ${REG_GPIO_INT_SENSTYPE_0_OFFSET[${GPIO_GROUP_NUM}]%%:*}`
OFFSET=`echo 0x${OFFSET:0:2} 0x${OFFSET:2:2}`
BASEADDR=`echo 0x${REG_GPIO_BASE:0:2} 0x${REG_GPIO_BASE:2:2}`

CMD="ipmitool -H ${IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 ${BASEADDR} ${OFFSET}"
get_rawdata_bytes "${CMD}"
if [ $? -eq 1 ]; then
    echo -e -n " -----> \033[31mrising-edge or level-high mode\033[0m(bit${GPIO_NUM})\n\n"
else
    echo -e -n " -----> \033[31mfalling-edge or level-low mode\033[0m(bit${GPIO_NUM})\n\n"
fi

#------ Interrupt Sensitivity Type 1 Register ------#
GPIO_NAME="GPIO${GPIO_GROUP_CHAR}${GPIO_NUM}"
GPIO_ADDR="0x${REG_GPIO_BASE}${REG_GPIO_INT_SENSTYPE_1_OFFSET[$GPIO_GROUP_NUM]}"
GPIO_DESC="\033[33mInterrupt Sensitivity Type 1\033[0m"
echo -e "*** Get ${GPIO_NAME} raw data from ${GPIO_DESC} Register (${GPIO_ADDR}) ***"

OFFSET=`echo ${REG_GPIO_INT_SENSTYPE_1_OFFSET[${GPIO_GROUP_NUM}]%%:*}`
OFFSET=`echo 0x${OFFSET:0:2} 0x${OFFSET:2:2}`
BASEADDR=`echo 0x${REG_GPIO_BASE:0:2} 0x${REG_GPIO_BASE:2:2}`

CMD="ipmitool -H ${IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 ${BASEADDR} ${OFFSET}"
get_rawdata_bytes "${CMD}"
if [ $? -eq 1 ]; then
    echo -e -n " -----> \033[31mlevel trigger mode\033[0m(bit${GPIO_NUM})\n\n"
else
    echo -e -n " -----> \033[31medge trigger mode\033[0m(bit${GPIO_NUM})\n\n"
fi

#------ Interrupt Sensitivity Type 2 Register ------#
GPIO_NAME="GPIO${GPIO_GROUP_CHAR}${GPIO_NUM}"
GPIO_ADDR="0x${REG_GPIO_BASE}${REG_GPIO_INT_SENSTYPE_2_OFFSET[$GPIO_GROUP_NUM]}"
GPIO_DESC="\033[33mInterrupt Sensitivity Type 2\033[0m"
echo -e "*** Get ${GPIO_NAME} raw data from ${GPIO_DESC} Register (${GPIO_ADDR}) ***"

OFFSET=`echo ${REG_GPIO_INT_SENSTYPE_2_OFFSET[${GPIO_GROUP_NUM}]%%:*}`
OFFSET=`echo 0x${OFFSET:0:2} 0x${OFFSET:2:2}`
BASEADDR=`echo 0x${REG_GPIO_BASE:0:2} 0x${REG_GPIO_BASE:2:2}`

CMD="ipmitool -H ${IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 ${BASEADDR} ${OFFSET}"
get_rawdata_bytes "${CMD}"
if [ $? -eq 1 ]; then
    echo -e -n " -----> \033[31mdual-edge trigger mode\033[0m(bit${GPIO_NUM})\n\n"
else
    echo -e -n " -----> \033[31medge or level trigger mode\033[0m(bit${GPIO_NUM})\n\n"
fi

