#!/bin/bash
sh /conf/aa.sh
fbapp --set-as-fb
LONG="$1"
n=0

while [ "$n" -lt 20 ]
do
echo -e $n
c=$(( $n * 8 ))
        while [ "$count" -lt 10 ]
        do
                a=$( printf %d 0xd3080000 )
                b=$(( $count * 3200 ))
                d=$(( $a + $b + $c ))
                e=$( printf %x $d )
                devmem 0x$e 64 0xFFFFFFFFFFFFFFFF
                count=$(( count+1 ))
        done
count=0
n=$(( n+1 ))
done
