#!/bin/sh

WORKSPACE_PATH=/home/jerry/codebase/ikvm_stunnel/x11/FileSystem/Host/AST2500/rootfs
WORKSPACE_IP=10.138.160.228

MOUNT1=bin
MOUNT2=lib

VM_DAEMON_NAME="vmd"
STUNNEL_DAEMON_NAME="stunneld"
IKVM_DAEMON_NAME=ikvmd

HID_MODULE_NAME=usb_hid
VIDEO_DRIVER_NAME=video_drv
IKVM_MASS_STORAGE_NAME=ikvm_vmass

echo "[Jerry] Stop DAEMON"
/etc/init.d/$IKVM_DAEMON_NAME stop
sleep 0.5
/etc/init.d/$STUNNEL_DAEMON_NAME stop
sleep 0.5
/etc/init.d/$VM_DAEMON_NAME stop
sleep 0.5

echo "[Jerry] Remove module"
rmmod $HID_MODULE_NAME
sleep 0.5
rmmod $VIDEO_DRIVER_NAME
sleep 0.5
rmmod $IKVM_MASS_STORAGE_NAME
sleep 0.5

echo "[Jerry] Mount folder"
mount -o nolock -t nfs $WORKSPACE_IP:$WORKSPACE_PATH/$MOUNT1 /$MOUNT1
mount -o nolock -t nfs $WORKSPACE_IP:$WORKSPACE_PATH/$MOUNT2 /$MOUNT2
sleep 0.5

echo "[Jerry] Insert module"
insmod /bin/module/$IKVM_MASS_STORAGE_NAME.ko
sleep 0.5
insmod /bin/module/$VIDEO_DRIVER_NAME.ko
sleep 0.5
insmod /bin/module/$HID_MODULE_NAME.ko
sleep 0.5

echo "[Jerry] Start DAEMON"
/etc/init.d/$IKVM_DAEMON_NAME start
sleep 0.5
/etc/init.d/$STUNNEL_DAEMON_NAME start
sleep 0.5
/etc/init.d/$VM_DAEMON_NAME start
sleep 0.5
echo "[Jerry] NFS mount Finished...!!!"
