#!/bin/bash

reboot_cnt=0
cnt=0
MAX=30
while [ 1 ]
do
    PCH_STAT=`ipmitool -H 10.138.160.91 -U ADMIN -P ADMIN sdr elist | grep "PCH Temp"`

    case $PCH_STAT in
        *"ok"*)
            cnt=$((cnt + 1))

            if [ $cnt -eq $MAX ];then
                cnt=0
                ipmitool -H 10.138.160.91 -U ADMIN -P ADMIN power cycle > /dev/null
                reboot_cnt=$((reboot_cnt+1))
                printf "reboot:%d \r" $reboot_cnt
                sleep 80
            fi
            ;;
    esac

    sleep 0.5
done
