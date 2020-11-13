#!/bin/sh

IP=$1
shift
COMMAND=$1
ALL_ARGU=$@

usage () {
    echo -e ""
    echo -e "myipmi usage: ./myipmi.sh [ip] [Raw Commands]"
    echo -e ""
    echo -e "Raw Commands:"
    echo -e "              \e[33mKey words\e[0m            \e[33mPurpose\e[0m                        \e[33mResponse\e[0m                                           \e[33mParameters\e[0m"
    echo -e "       \e[36mSensor\e[0m"
    echo -e "              [SENSOR_DISABLE]     - Enable sensor reading        -                                                  - 0x30 0x70 0xdf"
    echo -e "              [SENSOR_ENABLE]      - Disable sensor reading       -                                                  - 0x30 0x70 0x3a 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"
    echo -e "              [SENSOR_FLAG]        - Check BMC Sensor Flags       - (at_b_smbus_access_granted)(at_b_BMCSensorStart) - 0x30 0x70 0x3f"
    echo -e "       \e[36mFan\e[0m"
    echo -e "              [FAN_DEBUG]          - Enable Fan Control Debug     -                                                  - 0x30 0x70 0xfa 0x1"
    echo -e "              [FAN_DUTY]           - Get Fan Duty Cycle           -                                                  - 0x30 0x70 0xfa fan_index"
    echo -e "              [FAN_CONTROL]        - Set Fan Control              -                                                  - 0x30 0x70 0x66 Get/Set fan_index (Fan_duty)"
    echo -e "              [FAN_TEMPandDUTY]    - Get Sensor Temp And Duty     - (CPU temperature)(FAN duty cycle)                - 0x30 0x70 0x88 fan_index"
    echo -e "       \e[36mCPLD\e[0m"
    echo -e "              [CPLD_VERSION]       - Check MB CPLD version        -                                                  - 0x30 0x68 0x28 0x03"
    echo -e "              [CPLD_KEY]           - Check MB CPLD key            - 2 (debug_key) 1 (productoin_key)                 - 0x30 0x68 0x28 0x0a"
    echo -e "              [PROVISION]          - Check MB provisioned status  - (00) Not (01) Already                            - 0x30 0x68 0x28 0x00"
    echo -e "              [CPLD_18h]           - Get CPLD 0x18                - bit 1 (PCH released) bit 5 (PCH BOOT OK)         - 0x30 0x68 0x28 0x09"
    echo -e "              [SENSOR_POLLING_VAR] - Sensor polling variables     - (at_b_OemEnableSensor)(at_b_HWM_FAN_init_done)   - 0x30 0x68 0x28 0x0b"
    echo -e "                                                                    (at_b_SensorScanningEnable)(at_FW_UpdateMode)"
    echo -e "                                                                    (at_b_smbus_access_granted)(I2CAccessCheck())"
    echo -e "              [CPLD_REG]           - Get CPLD reg                 -                                                  - 0x30 0x70 0xdb 0x01 Data0 Data1 Data2"
    echo -e "                                                                                                                                           0x03  reg           Read CPLD reg"
    echo -e "                                                                                                                                           0x04  reg   data    Write CPLD reg"
    echo -e "                                                                                                                     - Detail refer IPMI/IPMI_CMDS/OEM/ROTSubCmd.c +453"
    echo -e "       \e[36mGet/Set Register\e[0m"
    echo -e "              [READ_REGISTER]      - Get memory register          - ([1] Data length 1: 8 bit 2: 16 bit 4: 32 bit    - 0x30 0x70 0xc0 (Data Len) (Register address)"
    echo -e "              [WRITE_REGISTER]     - Set memory register          - [2:5] Register address [6:9] Write data (32bit)) - 0x30 0x70 0xc1 (Data Len) (Register address) (Write data 32bit)"
    echo -e "       \e[36mGet/Set GPIO\e[0m"
    echo -e "              [GET_SET_GPIO]       - Get/Set GPIO                 - [1] 0:read  1:write [2] GPIO pin (define << 20)  - 0x30 0x70 0x4B (Read/Write) (GPIO pin <<20) (dir) (data) ()"
    echo -e "                                                                    [3] dir [4] data [5] 0:push-pull 1:open drain"
    echo -e "                                                                    EX: [IPMI/GPIO_DRV/OS/Linux/inc/gpio.h] #define GPIOE4_BMC_BIOS_UPDATE_N 0x04400000"
    echo -e "                                                                    ipmitool -H $IP -U ADMIN -P ADMIN raw 0x30 0x70 0x4B 0x0 0x44 //read GPIOE4"
    echo -e "       \e[36mUID LED control\e[0m"
    echo -e "              [UID_LED_ENABLE]     - Enable  UID LED              -                                                  - 0x30 0xD "
    echo -e "              [UID_LED_DISABLE]    - Disable UID LED              -                                                  - 0x30 0xE "
    echo -e "       \e[36mInfo\e[0m"
    echo -e "              [GET_SYSTEM_GUID]    - Get system GUID              - 36 31 30 31 4d 53 00 25 90 5e ab 42 00 00 00 00  - 0x6 0x37 "
    echo -e "                                                                    System GUID: first 6 bytesm  MAC Address: 7~12 Bytes, Reserve: 13~16 Bytes"
    echo -e "              [GET_DEVICE_GUID]    - Get device GUID              - 20 01 09 22 02 bf 7c 2a 00 63 09 01 10 00 00     - 0x6 0x1 "
    echo -e "                                                                    [1]DevID [2]DeviceRev [3]FirmwareRev1 [4]FirmwareRev2 [5]IPMIVer [6]AddtnlDevSup [7]ManfID [8 ]ManfID [9]ManfID"
    echo -e "                                                                    [10]PltBoardID [11]PltBoardID [12] FirmwareRev3 [14]Reserved [15]Reserved [13]FirmwareType: 00h=OFFICIAL, 10h=BETA, 20h=OEM, SignFW |= 1"
    echo -e "              [GET_HW_INFO]        - Get HW info                  - ([1]Board ID:L [2]Board ID:H [2]HW Monitor       - 0x30 0x21"
    echo -e "              [SET_HW_INFO]        - Set HW info                  - [3]HW Config [4~9] System LAN MAC address)       - 0x30 0x20 (Board ID) (HW Monitor) (HW Config) (MAC)"
    echo -e "       \e[36mBMC Reset\e[0m"
    echo -e "              [BMC_COLD_RESET]     - BMC cold reset               -                                                  - 0x6 0x2"
    echo -e "              [BMC_WARM_RESET]     - BMC warm reset               -                                                  - 0x6 0x3"
    echo -e "       \e[36mSet to default\e[0m"
    echo -e "              [FACTORY_DEFAULT]    - Reset To Factory Default     -                                                  - 0x30 0x40"
    echo -e "              [FRU_DEFAULT]        - Restore FRU to Default       -                                                  - 0x30 0x41"
    #echo -e "              []        -        -  - "
}

if [ "$IP" == "help" ] || [ -z $IP ]; then
    usage
    exit
fi

echo [$IP] [$COMMAND] [$ALL_ARGU]

case $COMMAND in
help)
    usage
    exit
;;

#Sensor
SENSOR_ENABLE)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x3a 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
;;
SENSOR_DISABLE)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xdf
;;
SENSOR_FLAG)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x3f
;;

#FAN
FAN_DEBUG)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xfa 0x1
;;
FAN_DUTY)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xfa $PRA
;;
FAN_CONTROL)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x66 $PRA
;;
FAN_TEMPandDUTY)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x88 $PRA
;;

#CPLD
PROVISION)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x00
;;
CPLD_VERSION)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x03
;;
CPLD_KEY)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x0a
;;
CPLD_18h)
    echo -e "bit 1 (PCH released) bit 5 (PCH BOOT OK)"
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x09
;;
SENSOR_POLLING_VAR)
    echo -e "(at_b_OemEnableSensor)(at_b_HWM_FAN_init_done)(at_b_SensorScanningEnable)(at_FW_UpdateMode)(at_b_smbus_access_granted)(I2CAccessCheck())"
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x0b
;;
CPLD_REG)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xdb 0x01 $PRA
;;

#Register
READ_REGISTER)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xC0 $PRA
;;
WRITE_REGISTER)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xC1 $PRA
;;

#GPIO
GET_SET_GPIO)
    shift
    PRA=$@
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x4B $PRA
;;

#UID LED
UID_LED_ENABLE)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0xD
;;
UID_LED_DISABLE)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0xe
;;

#Info
GET_SYSTEM_GUID)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x6 0x37
;;
GET_DEVICE_GUID)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x6 0x01
;;
GET_HW_INFO)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x21
;;
SET_HW_INFO)
    shift
    PRA=$@
    echo $PRA
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x20 $PRA
;;

#BMC reset
BMC_COLD_RESET)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x6 0x2
;;
BMC_WARM_RESET)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x6 0x3
;;

#Set to default
FACTORY_DEFAULT)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x6 0x3
;;
FRU_DEFAULT)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x6 0x3
;;

#Others
*)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw $ALL_ARGU
;;
esac
