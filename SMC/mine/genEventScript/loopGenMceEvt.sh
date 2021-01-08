#!/bin/bash
START=$1
END=$2

data1=0xA5

ERRTYPE="0 1 2 4 8"
for (( i = 0; i <= 8; i++ ));
do
    #BankType
    data3=`printf "0x%02x" $(($i))`
    for j in $ERRTYPE
    do
        data3=`printf "0x%02x" $(($j<<4))`
        tmp=$data3
        for (( k = 0; k < 4; k++ ));
        do
            #Severity
            data3=`printf "0x%02x" $((($data3 | ($k << 1))))`
            for (( h = 0; h < 2; h++ )); do
                data3=`printf "0x%02x" $(($data3 | $h))`
                ./genEveLog.sh 1 $data1 $data2 $data3 >> /dev/null
                sleep 0.3
                ./genEveLog.sh 0 $data1 $data2 $data3 >> /dev/null
            done
            data3=$tmp
        done
    done
done
