#!/bin/sh

IP=$1
shift
ARGU=$@

echo [$IP] [$ARGU]

ipmitool -H $IP -U ADMIN -P ADMIN -I lanplus raw $ARGU
