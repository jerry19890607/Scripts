#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       1. navigate to target folder
#       2. cpyCodebase.sh $CODEBASE
#   Comment:
#       Only support x11 and x12 now

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
        echo "$CODEBASE.tar exist!  Remove old one..."
        echo ""
        rm -r $CODEBASE.tar
    fi

    echo "Compress the $CODEBASE to a new tarball..."
    echo ""

    tar -cf $CODEBASE.tar $CODEBASE
    if [ $? -eq 0 ]; then
        echo "$CODEBASE.tar is ready!"
    else
        echo "Compress $CODEBASE.tar ERROR!!"
        exit
    fi

    if [ -d $CODEBASE ]; then
        echo "Copy $CODEBASE.tar to $DES ..."
        echo ""

        tar -xf $CODEBASE.tar -C $DES/
        if [ $? -eq 0 ]; then
            echo "Remove $CODEBASE.tar"
            rm $CODEBASE.tar
        else
            echo "Decompress $CODEBASE.tar to $DES ERROR!!"
            exit
        fi

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
