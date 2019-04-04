#!/bin/sh
declare -i Counter=10
Counter=0
#(Counter++)
#echo $Counter
#echo "Counter Outside---> " $Counter
while [ 1 ]
do
	#(Counter++)
	Counter=Counter+1
	echo "Counter---> " $Counter
	ipmitool -H 172.16.68.120 -I lanplus -U bmcadmin -P bmcadmin power off
	sleep 30
	ipmitool -H 172.16.68.120 -I lanplus -U bmcadmin -P bmcadmin power on
	echo "waiting for 60Sec"
	sleep 60
	echo "Sending Up"
	xdotool key Up
	sleep 10
	echo "Sending Enter"
	xdotool key Return
	sleep 3m
done
