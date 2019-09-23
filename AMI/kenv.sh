#!/bin/sh

# Usage: 
#  $cd out/
#  $source kenv.sh {workspace}

Create_Sym_Link()
{
	
    if [ -f "arm-linux-$1" ]
    then
        echo "Delete file arm-linux-$1"
        rm -rf arm-linux-$1
    fi
	echo "create sym link arm-none-linux-gnueabi-${1}"
	ln -s arm-none-linux-gnueabi-${1} arm-linux-${1} 
}

if [ "$1" == "" ]
then
	echo "Please input workspace"
	return 0
	exit 1
fi

#echo "Parameter: ${1}"
cd $1
WORKSPACE=$(pwd)
#echo "workspace ${WORKSPACE}"
cd -

cd $WORKSPACE/tools/arm-linux/arm-none-linux-gnueabi/bin
echo "GOTO gcc path: $(pwd)"
Create_Sym_Link gcc
Create_Sym_Link ld
Create_Sym_Link ld.bfd
Create_Sym_Link ar
Create_Sym_Link nm 
Create_Sym_Link objcopy 
Create_Sym_Link size 
Create_Sym_Link readelf 
Create_Sym_Link strip
cd -

echo "Export [${WORKSPACE}/tools/arm-linux/arm-none-linux-gnueabi/bin] and [${WORKSPACE}/tools/buildtools/] to PATH"
export PATH=$PATH:${WORKSPACE}/tools/arm-linux/arm-none-linux-gnueabi/bin:${WORKSPACE}/tools/buildtools/
echo "Export [${WORKSPACE}/Build/include] to SPXINC"
export SPXINC=${WORKSPACE}/Build/include
echo "Export [arm-linux-] to CROSS_COMPILE"
export CROSS_COMPILE="arm-linux-"
echo "Export [arm] to CROSS_ARCH"
export ARCH=arm

return 0
