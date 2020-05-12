#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#		. cpyCodebase.sh $CODEBASE

CODEBASE=$1
DES=$(pwd)
PURE_PATH=/home/jerry/codebase/Pure

if [ -d $PURE_PATH ]; then
    cd $PURE_PATH
    if [ -f $CODEBASE.tar.gz ]; then
        echo "Remove old tarball..."
        rm $CODEBASE.tar.gz
    fi
    if [ -d $CODEBASE ]; then
        tar -zcf $CODEBASE.tar.gz $CODEBASE
        tar -xzf $CODEBASE.tar.gz -C $DES/
        rm $CODEBASE.tar.gz &&
        cd $DES/$CODEBASE/
    else
        echo "Copy fail !!"
        exit
    fi
    echo ""
    echo "Copy [$CODEBASE] to [$DES] finished !!"
    echo ""
else
    echo "Copy fail !!"
    exit
fi
