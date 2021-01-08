#!/bin/bash
START=$1
END=$2

[ -z $START ] || [ -z $END ] && echo "Please input start ~ end" && exit 1

for (( i = $START; i <= $END; i++ )); do
    val=`printf "0x%02x" $i`
    ./genEveLog.sh 0x80 $val >> /dev/null
    sleep 0.5
done
