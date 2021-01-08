#!/bin/bash
START=$1
END=$2

ERRTYPE="0 1 2 4 8"
for (( i = 0; i <= 8; i++ ));
do
    #BankType
    data1=`printf "0x%02x" $(($i))`
    for j in $ERRTYPE
    do
        data2=`printf "0x%02x" $(($j<<4))`
        tmp=$data2
        for (( k = 0; k < 4; k++ ));
        do
            #Severity
            data2=`printf "0x%02x" $((($data2 | ($k << 1))))`
            for (( h = 0; h < 2; h++ )); do
                data2=`printf "0x%02x" $(($data2 | $h))`
                ./genEveLog.sh $data1 $data2 >> /dev/null
            done
            data2=$tmp
        done
    done
done
