#!/bin/sh

IP=$1
USER="ADMIN"
PWD="ADMIN"

NUM=$#

if [ $NUM -eq 1 ] || [ $NUM -gt 2 ] || [[ $IP == "help" ]]; then
    echo 'Usage:'
    echo '      ./i2cScanner.sh $IP $I2C_BUS'
    exit
fi

# Disable senser reading
VAR=`ipmitool -H $IP -U $USER -P $PWD raw 0x30 0x70 0xdf 0 2>&1`
if [[ $VAR =~ "Could not open socket" ]];
then
        echo 'IP invalid!'
        echo 'Usage:'
        echo '      ./i2cScanner.sh $IP $I2C_BUS'
        exit
fi

ADDRESS=0
BUS=$(($2*2+1))

while [ $ADDRESS -le 255 ]
do
        # Read i2c bus adress form 0x0 to 0xff
        VAR=`ipmitool -H $IP -U $USER -P $PWD raw 0x6 0x52 $BUS $ADDRESS 1 0x0 2>&1`

        if [[ $VAR =~ "send RAW command" ]];
        then
                :
        else
                BITADD=$((ADDRESS*2))
                printf "%X" $ADDRESS
                #printf 'ipmitool -H $IP -U $USER -P $PWD raw 0x6 0x52 $BUS $ADDRESS 1 0x0' $IP $USER $PWD $BUS $ADDRESS
                echo ''
        fi
        ADDRESS=$(( ADDRESS+2 ))
done
