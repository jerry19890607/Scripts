#!/bin/bash

echo "                   __---__                         ______                     "
echo "                  /    ___\_             o  O  O _(      )__                  "
echo "                 /====(_____\___---_  o        _(           )_                "
echo "                |                    \        (_  AI-YA!!!!   )               "
echo "                |                     |@        (_  Shot      _)              "
echo "                 \       ___         /           (__  Again!__)               "
echo "    \ __----____--_\____(____\_____/                (______)                  "
echo "   ==|__----____--______|                                                     "
echo "    /              /    \____/)_                                              "
echo "                 /        ______)                                             "
echo "                /           |  |                                              "
echo "               |           _|  |                                              "
echo "          ______\______________|______                                        "
echo "         /                    *   *   \                                       "
echo "        /_____________*____*___________\                                      "
echo "        /   *     *                    \                                      "
echo "       /________________________________\                                     "
echo "       / *                              \                                     "
echo "      /__________________________________\                                    "
echo "           |                        |                                         "
echo "           |________________________|                                         "
echo "           |                        |                                         "
echo "           |________________________|                                         "
echo ""
echo ""
echo ""

vbat_low=2600
vbat_fail=2500

if [ -n "$1" ]; then
    IPMI_IP=$1
else
    IPMI_IP=10.138.160.106
fi


echo "*** Get VBAT raw data from ADC register (0x1E6E9014) ***"
ipmicmd="ipmitool -H ${IPMI_IP} -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 0x1E 0x6E 0x90 0x14"
echo "${ipmicmd}"
rawData=`${ipmicmd}`
if [ -z "$rawData" ]; then
    exit 1
else
    echo -e ">${rawData}\n"
fi

# Remove unnecessary blanks
rawData=`echo ${rawData//[[:blank:]]/}`

rawData2Bin=`echo "ibase=16; obase=2;" ${rawData^^} | bc`
rawData2Bin_display=`printf "%32s\n" $rawData2Bin|tr ' ' '0'`
rawData2Bin_P1=`echo ${rawData2Bin_display:${#rawData2Bin_display}-32:6}`
rawData2Bin_P2=`echo ${rawData2Bin_display:${#rawData2Bin_display}-26:10}`
rawData2Bin_P3=`echo ${rawData2Bin_display:${#rawData2Bin_display}-16:16}`
rawDataDesc="Bit[25:16] Data of Channel 3"
echo -e "${rawData2Bin_P1}\033[31m${rawData2Bin_P2}\033[0m${rawData2Bin_P3}"
echo "      23^     15^      7^     0^"
echo -e "\n*** ${rawDataDesc} ***"

rawData2Bin=`echo ${rawData2Bin:0:-16}`
if [ ${#rawData2Bin} -gt 10 ]; then
    rawData2Bin=`echo ${rawData2Bin:$((${#rawData2Bin}-10)):10}`
    echo ${rawData2Bin}
fi

echo -n "${rawData2Bin} = "
hexValue_org=`printf '%x\n' "$((2#${rawData2Bin}))"`
rawData2Bin=`echo ${rawData2Bin:0:-2}`
hexValue=`printf '%x\n' "$((2#${rawData2Bin}))"`
decValue=`echo "ibase=16; " ${hexValue_org^^} | bc`
echo "${decValue}(dec)"
echo "${rawData2Bin}   = 0x${hexValue}"

echo -e -n "\n> Please input the actual voltage(mV): "
read voltage_org

# ASPEED 2500 SPEC > ADC I/O Parameters > VREFP max voltage is 1.8V
mVunit=$(awk 'BEGIN{print 1800/1024 }')
voltage=$(awk 'BEGIN{print "'"${mVunit}"'"*"'"${decValue}"'" }')
divided_Voltage=$(awk 'BEGIN{print "'"${voltage_org}"'"/"'"${voltage}"'" }')
echo "divided voltage is 1/${divided_Voltage}"

voltageLow=$(awk 'BEGIN{print "'"${vbat_low}"'"/"'"${divided_Voltage}"'"/"'"${mVunit}"'" }')
echo -e "\n[VBAT Low] ${vbat_low}mV"

voltageLow2Bin=`echo "obase=2;${voltageLow%.*}" | bc`
echo "${voltageLow2Bin} = ${voltageLow%.*}(dec)"
voltageLow2Bin=`echo ${voltageLow2Bin:0:-2}`
voltageLow2Hex=`printf '%x\n' "$((2#${voltageLow2Bin}))"`
echo -e "${voltageLow2Bin} = \033[31m0x${voltageLow2Hex}\033[0m"

voltageFail=$(awk 'BEGIN{print "'"${vbat_fail}"'"/"'"${divided_Voltage}"'"/"'"${mVunit}"'" }')
echo -e "\n[VBAT Fail] ${vbat_fail}mV"

voltageFail2Bin=`echo "obase=2;${voltageFail%.*}" | bc`
echo "${voltageFail2Bin} = ${voltageFail%.*}(dec)"
voltageFail2Bin=`echo ${voltageFail2Bin:0:-2}`
voltageFail2Hex=`printf '%x\n' "$((2#${voltageFail2Bin}))"`
echo -e "${voltageFail2Bin} = \033[31m0x${voltageFail2Hex}\033[0m\n"

