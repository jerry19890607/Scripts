#!/bin/bash
GPIO=./GPIO_Ninja.sh
#IP=10.138.161.10
IP=10.138.160.231
PIN=g7
TIMES=0
MAX_TIMES=300
file=gpio_${IP}.txt
echo "" > $file
while [ 1 ]
do
    TIMES=$((TIMES + 1))
    #[ $TIMES -eq $MAX_TIMES ] && break
    echo "=========$TIMES==========" >> $file
    #$GPIO $IP $PIN >> $file
    ipmitool -H $IP -U ADMIN -P ADMIN raw 0x30 0x70 0xc0 0x4 0x1E 0x78 0x00 0x20 >> $file
    sleep 0.2
done

echo "done"
