#!/bin/bash

#Execute under BMC console, copy web and mount back to build machine

#usage sh /nv/m.sh IP [-cp]

NFS_PATH_PC=/home/jerry/ssd/nfs
NFS_PATH_BMC=/tmp/nfs
NFS_SERVER_IP=$1
CMD_CP=$2
echo $NFS_SERVER_IP $CMD_CP


umount $NFS_PATH_BMC
mkdir $NFS_PATH_BMC; mount -t nfs -o nolock $NFS_SERVER_IP:$NFS_PATH_PC $NFS_PATH_BMC


if [ $? -ne 0 ];then
	echo no ok;
	exit 0;
else
	echo ok;
fi

# Copy web at first time
if [ -n "$CMD_CP" ];then
	rm -rf $NFS_PATH_BMC/web;
	cp /web/ $NFS_PATH_BMC/web/ -rf;
	chmod 777 -R $NFS_PATH_BMC/web;
fi

mount $NFS_PATH_BMC/web /web

#For debug ipmi changes (except cgi)
mount -o ro,bind $NFS_PATH_BMC/libipmi.so /lib/libipmi.so
