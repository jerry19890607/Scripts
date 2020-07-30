#!/bin/sh
#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       [Only x12 need new WebGUI]
#       1. navigate to x12 codebase
#       2. upWebSrc.sh

SRCPATCH=$(pwd)
WEBSRC=/home/jerry/codebase/Pure/webgui_gen2
WEBPATCH=$SRCPATCH/Web_Server/web/SUPERMICRO

echo ""
echo "Update [$WEBSRC] to [$WEBPATCH]"
echo ""

if [ $# -ge 1 ]; then
    echo "The script no need arguments!"
    exit
fi

if [ -d $WEBSRC ]; then
    cd $WEBSRC
    echo "Update web source git..."
    git pull
    echo "Already update to HEAD!!"
    echo ""
else
    echo "[$WEBSRC] incorrect"
    exit
fi

if [ -d $WEBPATCH ]; then
    cd $WEBPATCH
    echo "Remove and copy..."
    if [ -d css/ ]; then
        rm -r css/
    fi
    if [ -d css/ ]; then
        rm -r css/
    fi
    if [ -d js/ ]; then
        rm -r js/
    fi
    if [ -d images/ ]; then
        rm -r images/
    fi
    cp -r $WEBSRC/css/ $WEBSRC/js/ $WEBSRC/page/ $WEBSRC/images/ $WEBPATCH/
    echo "Already copy to HEAD!!"
    echo ""
else
    echo "[$WEBPATCH] incorrect"
    exit
fi
