#!/bin/bash

# syntax:
#     program bmcIp
#

# Date: Nov 05, 2019

ipAddr=$1

if [ "$ipAddr" == "" ]; then
    echo "Please specify BMC IP address"
    exit
fi

function printBbmLut {
    local localStr="$1"
    localStr="${localStr//$'\n'/ }"
    read -a ARRAY <<< "$localStr"
    arraySize=${#ARRAY[@]}
    for (( i=0; i<$arraySize; i=i+4 ))
    do
        if [[ "${ARRAY[i]}" != "00" || "${ARRAY[i+1]}" != "00" || "${ARRAY[i+2]}" != "00" || "${ARRAY[i+3]}" != "00" ]]; then
            echo "  ${ARRAY[i]}${ARRAY[i+1]} <=> ${ARRAY[i+2]}${ARRAY[i+3]}"
        fi
    done
}

# convert a list of hex numbers to ASCII
function hex2Ascii {
    local localStr="$1"
    localStr="${localStr//$'\n'/ }"
    read -a ARRAY <<< "$localStr"
    arraySize=${#ARRAY[@]}
    for (( i=0; i<$arraySize; i=i+1 ))
    do
       printf "\x${ARRAY[i]}"
    done
}

# " 00" passed
# else  failed
function passFailed {
    local val=$1
    if [ $((val)) == 0 ]; then
        echo "PASSED"
    else
        echo "FAILED"
    fi
}

# remove any white spaces
function trimSpaces {
    echo -n "${1//[[:space:]]/}"
}

# format ipmitool BMC version
# DD.HH => HH.HH
function bmcVerFormat {
    local ver=$1
    local major="$(cut -d'.' -f 1 <<< $ver)"
    local fwVerMin="$(cut -d'.' -f 2 <<< $ver)"
    local fwVerMaj=$(((($major / 16 ) * 10) + ($major % 16)))
    printf "%02d.$fwVerMin" $((fwVerMaj))
}

# convert first two values in a list of hex numbers to HH.HH
function verMajMin {
    local localStr="$1"
    localStr="${localStr//$'\n'/ }"
    read -a ARRAY <<< "$localStr"
    local fwVerMaj=${ARRAY[0]}
    local fwVerMin=${ARRAY[1]}
    local fwVerSub=${ARRAY[2]}
    echo "$fwVerMaj.$fwVerMin.$fwVerSub"
}

ipmiToolPre="ipmitool -H $ipAddr -U ADMIN -P ADMIN"

when=`date`
ret=`$ipmiToolPre raw 0x30 0x70 0xb1 0x00`
if [ "$ret" == " 00" ]; then
    provStatus="Not Done"
elif [ "$ret" == " 01" ]; then
    provStatus="Done"
else
    provStatus="Unknown"
fi

echo "Getting MC info ..."
boardId=`$ipmiToolPre mc info | grep "Product ID" | sed "s|.*(0x||" | sed "s|)||"`
macAddr=`$ipmiToolPre lan print | grep "MAC Address" | sed "s|.* ||"`
echo "Getting BBM LUT ..."
bbmLut0=`$ipmiToolPre raw 0x30 0x70 0xdb 1 0x10 0`
bbmLut1=`$ipmiToolPre raw 0x30 0x70 0xdb 1 0x10 1`

echo "Getting CPLD version ..."
cpldVersion=`$ipmiToolPre -N 10 raw 0x30 0x70 0xb1 3`
cpldVersionStr=$(trimSpaces "$cpldVersion")

echo "Getting image versions ..."
echo "$ipmiToolPre -N 30 raw 0x30 0x70 0xb1 6 0 3"
bmcVerNor=`$ipmiToolPre -N 30 raw 0x30 0x70 0xb1 6 0 3`
echo "$ipmiToolPre -N 30 raw 0x30 0x70 0xb1 6 0 1"
bmcVerNand1=`$ipmiToolPre -N 15 raw 0x30 0x70 0xb1 6 0 1`
echo "$ipmiToolPre -N 30 raw 0x30 0x70 0xb1 6 0 2"
bmcVerNand2=`$ipmiToolPre -N 15 raw 0x30 0x70 0xb1 6 0 2`
#biosVerNor=`$ipmiToolPre -N 15 raw 0x30 0x70 0xb1 6 1 3`
echo "$ipmiToolPre -N 30 raw 0x30 0x70 0xb1 6 1 1"
biosVerNand1=`$ipmiToolPre -N 15 raw 0x30 0x70 0xb1 6 1 1`
echo "$ipmiToolPre -N 30 raw 0x30 0x70 0xb1 6 1 2"
biosVerNand2=`$ipmiToolPre -N 15 raw 0x30 0x70 0xb1 6 1 2`
echo "-----"
bmcVerNorStr=$(verMajMin "$bmcVerNor")
bmcVerNand1Str=$(verMajMin "$bmcVerNand1")
bmcVerNand2Str=$(verMajMin "$bmcVerNand2")
biosVerNorStr=$(hex2Ascii "$biosVerNor")
biosVerNorStr=`echo "$biosVerNorStr" | sed "s|.*: ||" | sed "s|Rev ||"`
biosVerNand1Str=$(hex2Ascii "$biosVerNand1")
biosVerNand1Str=`echo "$biosVerNand1Str" | sed "s|.*: ||" | sed "s|Rev ||"`
biosVerNand2Str=$(hex2Ascii "$biosVerNand2")
biosVerNand2Str=`echo "$biosVerNand2Str" | sed "s|.*: ||" | sed "s|Rev ||"`

echo "Getting board ID ..."
biosBoardId1=`$ipmiToolPre raw 0x30 0x70 0xb1 7 1`
biosBoardId2=`$ipmiToolPre raw 0x30 0x70 0xb1 7 2`
biosBoardId1Str=$(trimSpaces "$biosBoardId1")
biosBoardId2Str=$(trimSpaces "$biosBoardId2")

echo "Validating images ..."
bmcSignCheck1=`$ipmiToolPre -N 10 raw 0x30 0x70 0xb1 5 0 1`
bmcSignCheck2=`$ipmiToolPre -N 10 raw 0x30 0x70 0xb1 5 0 2`
biosSignCheck1=`$ipmiToolPre -N 10 raw 0x30 0x70 0xb1 5 1 1`
biosSignCheck2=`$ipmiToolPre -N 10 raw 0x30 0x70 0xb1 5 1 2`
bmcSignCheck1Str=$(passFailed "$bmcSignCheck1")
bmcSignCheck2Str=$(passFailed "$bmcSignCheck2")
biosSignCheck1Str=$(passFailed "$biosSignCheck1")
biosSignCheck2Str=$(passFailed "$biosSignCheck2")

echo "Checking status ..."

# check overall status
# BMC1
bmc1Status=0
if [ "$bmcVerNorStr" != "$bmcVerNand1Str" ]; then
    bmc1Status=$bmc1Status+1
fi
if [ "$bmcSignCheck1Str" != "PASSED" ]; then
    bmc1Status=$bmc1Status+1
fi
bmc1StatusStr=$(passFailed "$bmc1Status")
# BMC2
bmc2Status=0
if [ "$bmcVerNorStr" != "$bmcVerNand2Str" ]; then
    bmc2Status=$bmc2Status+1
fi
if [ "$bmcSignCheck2Str" != "PASSED" ]; then
    bmc2Status=$bmc2Status+1
fi
bmc2StatusStr=$(passFailed "$bmc2Status")
# BIOS1
bios1Status=0
#if [ "$biosVerNorStr" != "$biosVerNand1Str" ]; then
#    bios1Status=$bios1Status+1
#fi
if [ "$boardId" != "$biosBoardId1Str" ]; then
    bios1Status=$bios1Status+1
fi
if [ "$biosSignCheck1Str" != "PASSED" ]; then
    bios1Status=$bios1Status+1
fi
bios1StatusStr=$(passFailed "$bios1Status")
# BIOS2
bios2Status=0
#if [ "$biosVerNorStr" != "$biosVerNand2Str" ]; then
#    bios2Status=$bios2Status+1
#fi
if [ "$boardId" != "$biosBoardId2Str" ]; then
    bios1Status=$bios2Status+1
fi
if [ "$biosSignCheck2Str" != "PASSED" ]; then
    bios2Status=$bios2Status+1
fi
bios2StatusStr=$(passFailed "$bios2Status")

overallStatus=$bmc1Status+$bmc2Status+$bios1Status+$bios2Status
overallStatusStr=$(passFailed "$overallStatus")


#===============
# Print result
#===============

echo "================"
echo "Provision status"
echo "================"
echo "Date                      : $when"
echo "BMC IP                    : $ipAddr"
echo "MAC Address               : $macAddr"
echo "CPLD Version              : $cpldVersionStr"
echo "Status                    : $provStatus [$overallStatusStr]"
echo "BBM LUT 0                 :"
printBbmLut "$bbmLut0"
echo "BBM LUT 1                 :"
printBbmLut "$bbmLut1"
echo ""

printf "%-15s %15s %20s %20s %20s %20s\n" ""             ""               "BMC1"              "BMC2"              "BIOS1"              "BIOS2"
echo   "-------------------------------------------------------------------------------------------------------------------"
printf "%-15s %15s %20s %20s %20s %20s\n" "BMC version"  "$bmcVerNorStr"  "$bmcVerNand1Str"   "$bmcVerNand2Str"   "-"                  "-"
printf "%-15s %15s %20s %20s %20s %20s\n" "BIOS version" "$biosVerNorStr" "-"                 "-"                 "$biosVerNand1Str"   "$biosVerNand2Str"
printf "%-15s %15s %20s %20s %20s %20s\n" "Board ID"     "$boardId"       "-"                 "-"                 "$biosBoardId1Str"   "$biosBoardId2Str"
printf "%-15s %15s %20s %20s %20s %20s\n" "Sign Check"   ""               "$bmcSignCheck1Str" "$bmcSignCheck2Str" "$biosSignCheck1Str" "$biosSignCheck2Str"
echo   "-------------------------------------------------------------------------------------------------------------------"
printf "%-15s %15s %20s %20s %20s %20s\n" ""             ""               "$bmc1StatusStr"    "$bmc2StatusStr"    "$bios1StatusStr"    "$bios2StatusStr"
