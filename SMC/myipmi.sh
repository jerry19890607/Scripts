#!/bin/sh

IP=$1
shift
ARGU=$@


if [ $IP == 'help' ]; then
    echo ""
    echo "myipmi usage:   *Key words*              *Purpose*                    *Response*                                         *Parameters*"
    echo "              [SENSOR_ENABLE]      - Enable sensor reading        -                                                  - 0x30 0x70 0xdf"
    echo "              [SENSOR_DISABLE]     - Disable sensor reading       -                                                  - 0x30 0x70 0x3a 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"
    echo "              [SENSOR_FLAG]        - Check BMC Sensor Flags       - (at_b_smbus_access_granted)(at_b_BMCSensorStart) - 0x30 0x70 0x3f"
    echo ""
    echo "              [FAN_DEBUG]          - Enable Fan Control Debug     -                                                  - 0x30 0x70 0xfa 0x1"
    echo "              [FAN_DUTY]           - Get Fan Duty Cycle           -                                                  - 0x30 0x70 0xfa fan_index"
    echo "              [FAN_CONTROL]        - Set Fan Control              -                                                  - 0x30 0x70 0x66 Get/Set fan_index (Fan_duty)"
    echo "              [FAN_TEMPandDUTY]    - Get Sensor Temp And Duty     - (CPU temperature)(FAN duty cycle)                - 0x30 0x70 0x88 fan_index"
    echo ""
    echo "              [CPLD_KEY]           - MB CPLD key?                 - (debug_key)(productoin_key)                      - 0x30 0x68 0x28 0x0a"
    echo "              []        -        -  - "
    echo ""
    exit
fi

echo [$IP] [$ARGU]

case $ARGU in
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

CPLD_KEY)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw 0x30 0x68 0x28 0x0a
;;
*)
    ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw $ARGU
;;
esac
