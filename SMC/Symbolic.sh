#/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       . Navigate to codebase (ex: /home/jerry/ssd/codebase/verify_uac_compress/x11)
#       . Symbolic.sh
#       . Will refresh the symbolic of /home/jerry/link
#       . Down


#if [ $(pwd | grep codebase) ] && [ -e .config] && ([ $(pwd | grep x11) ] || [ $(pwd | grep x10) || [ $(pwd | grep x12)]); then
if [ -d $(pwd)/FileSystem ] && [ -f $(pwd)/.config ]; then
    CODEBASES_PATH=$(pwd)
    echo "[ Codebase path: $CODEBASES_PATH ]"
    echo ""
else
    echo "You're in the worng path or need to build codebase before this script." 
    echo "Please Navigate to codebase path (ex: /home/jerry/ssd/codebase/\${CODENASE NAME}/x11)"
    echo "exit..."
    exit
fi

BIN_PATH=/home/jerry/link/bin
LIB_PATH=/home/jerry/link/lib
WEB_PATH=/home/jerry/link/web
IP="$(ifconfig eth2 | grep 10.138 | awk '{print $2}' | cut -d':' -f2)"

if [ -L $BIN_PATH ]; then
    rm $BIN_PATH
fi

if [ -L $LIB_PATH ]; then
    rm $LIB_PATH
fi

if [ -L $WEB_PATH ]; then
    rm $WEB_PATH
fi

echo "[ Create symbolic ]"
ln -s $CODEBASES_PATH/FileSystem/Host/AST2500/rootfs/bin $BIN_PATH
if [ $? -ne 0 ]; then
        echo "Create $BIN_PATH FAIL!!"
fi
ln -s $CODEBASES_PATH/FileSystem/Host/AST2500/rootfs/lib $LIB_PATH
if [ $? -ne 0 ]; then
        echo "Create $LIB_PATH FAIL!!"
fi
ln -s $CODEBASES_PATH/FileSystem/Host/AST2500/webfs $WEB_PATH
if [ $? -ne 0 ]; then
        echo "Create $WEB_PATH FAIL!!"
fi
ls -al $BIN_PATH $LIB_PATH $WEB_PATH
echo "[ Done!! ]"
echo ""

if [ -L $BIN_PATH ]; then
    echo "mount -o nolock -t nfs $IP:$BIN_PATH /bin"
fi

if [ -L $LIB_PATH ]; then
    echo "mount -o nolock -t nfs $IP:$LIB_PATH /lib"
fi

if [ -L $WEB_PATH ]; then
    echo "mount -o nolock -t nfs $IP:$WEB_PATH /web"
fi

if [ -L $BIN_PATH ] && [ -L $LIB_PATH ] && [ -L $WEB_PATH ]; then
    echo ""
    echo "mount -o nolock -t nfs $IP:$BIN_PATH /bin;mount -o nolock -t nfs $IP:$LIB_PATH /lib;mount -o nolock -t nfs $IP:$WEB_PATH /web"
fi
