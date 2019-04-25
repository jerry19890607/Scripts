#!/bin/sh
while [ 1 ]
do
	ssh root@192.168.0.156 'reboot'
	sleep 100
done
