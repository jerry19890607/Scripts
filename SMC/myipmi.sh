#!/bin/sh

IP=$1
shift
ARGU=$@

usage () {
    echo -e ""
    echo -e "myipmi usage: ./myipmi.sh {ip | help} {raw command | help}"
    echo -e ""
    echo -e "Commands:"
    echo -e "              \e[33mKey words\e[0m            \e[33mPurpose\e[0m                        \e[33mResponse\e[0m                                           \e[33mParameters\e[0m"
    echo -e ""
    echo -e "       \e[36mSensor\e[0m"
    echo -e "              [SENSOR_ENABLE]      - Enable sensor reading        -                                                  - 0x30 0x70 0xdf"
    echo -e "              [SENSOR_DISABLE]     - Disable sensor reading       -                                                  - 0x30 0x70 0x3a 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"
    echo -e "              [SENSOR_FLAG]        - Check BMC Sensor Flags       - (at_b_smbus_access_granted)(at_b_BMCSensorStart) - 0x30 0x70 0x3f"
    echo -e ""
    echo -e "       \e[36mFan\e[0m"
    echo -e "              [FAN_DEBUG]          - Enable Fan Control Debug     -                                                  - 0x30 0x70 0xfa 0x1"
    echo -e "              [FAN_DUTY]           - Get Fan Duty Cycle           -                                                  - 0x30 0x70 0xfa fan_index"
    echo -e "              [FAN_CONTROL]        - Set Fan Control              -                                                  - 0x30 0x70 0x66 Get/Set fan_index (Fan_duty)"
    echo -e "              [FAN_TEMPandDUTY]    - Get Sensor Temp And Duty     - (CPU temperature)(FAN duty cycle)                - 0x30 0x70 0x88 fan_index"
    echo -e ""
    echo -e "       \e[36mCPLD\e[0m"
    echo -e "              [CPLD_VERSION]       - Check MB CPLD version        -                                                  - 0x30 0x68 0x28 0x03"
    echo -e "              [CPLD_KEY]           - Check MB CPLD key            - 2 (debug_key) 1 (productoin_key)                 - 0x30 0x68 0x28 0x0a"
    echo -e "              [PROVISION]          - Check MB provisioned status  - (00) Not (01) Already                            - 0x30 0x68 0x28 0x0a"
    echo -e "              []        -        -  - "
    echo -e ""
}

if [ $IP == 'help' ]; then
    usage
    exit
fi

echo [$IP] [$ARGU]

case $ARGU in
help)
    usage
    exit
;;
SENSOR_ENABLE)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x3a 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
;;
SENSOR_DISABLE)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x3a 0x30 0x70 0xdf
;;
SENSOR_FLAG)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x3f
;;

FAN_DEBUG)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xfa 0x1
;;
FAN_DUTY)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0xfa $ARGU
;;
FAN_CONTROL)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x66 $ARGU
;;
FAN_TEMPandDUTY)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x70 0x88 $ARGU
;;

PROVISION)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x00
;;
CPLD_VERSION)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x03
;;
CPLD_KEY)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x0a
;;
*)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw $ARGU
;;
esac
