#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       1. navigate to target folder
#       2. cpyCodebase.sh $CODEBASE

CODEBASE=$1
DES=$(pwd)
PURE_PATH=/home/jerry/codebase/Pure

if [ -z "$1" ]; then
    echo "Please input arguments!"
    exit
fi

if [ "$CODEBASE" != "x11" ] && [ "$CODEBASE" != "x12" ]; then
    echo "Please input leagal codebase (x11 or x12)"
    echo ""
    exit
fi

if [ -d $PURE_PATH ]; then
    cd $PURE_PATH
    if [ -f $CODEBASE.tar ]; then
        echo "$CODEBASE.tar exist!  Update..."
        echo ""
        tar -uf $CODEBASE.tar $CODEBASE
    else
        echo "$CODEBASE.tar not exist!  New tar..."
        echo ""
        tar -cf $CODEBASE.tar $CODEBASE
    fi
    echo "$CODEBASE.tar is ready!"

    if [ -d $CODEBASE ]; then
        echo "Copy $CODEBASE.tar to $DES ..."
        echo ""
        tar -xf $CODEBASE.tar -C $DES/
        cd $DES/$CODEBASE/
        echo ""
        echo "Copy [$CODEBASE] to [$DES] finished !!"
        echo ""
    else
        echo "Copy fail !!"
        echo ""
        exit
    fi
else
    echo "Copy fail !!"
    echo ""
    exit
fi
