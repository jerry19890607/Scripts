#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       [Only x12 need new WebGUI]
#       1. navigate to x12 codebase
#       2. upWebSrc.sh


if [ ! -z "$(cat .git/config| grep x12)" ]; then
    CODEBASE=x12
elif [ ! -z "$(cat .git/config| grep x11)" ]; then
    echo -e "\e[38;5;199m x11 codebase  \e[0m"
    exit
elif [ ! -z "$(cat .git/config| grep x10)" ]; then
    echo -e "\e[38;5;199m x10 codebase  \e[0m"
    exit
else
    echo "Unrecognizable codebase! Exit..."
    exit
fi

SRCPATCH=$(pwd)
WEBSRC=/home/jerry/codebase/Pure/webgui_gen2
WEBPATCH=$SRCPATCH/Web_Server/web/SUPERMICRO

echo ""
echo -e "Update [\e[38;5;156m$WEBSRC\e[0m] to [\e[38;5;156m$WEBPATCH\e[0m]"
echo ""

if [ $# -ge 1 ]; then
    echo "The script no need arguments!"
    exit
fi

if [ -d $WEBSRC ]; then
    cd $WEBSRC
    echo "Update web source git..."
    git pull
    echo ""
else
    printf "\e[38;5;203m"
    echo "[$WEBSRC] incorrect"
    printf "\e[0m"
    exit
fi

HEADVER=$(git rev-parse --short HEAD)

echo -e "Back up \e[38;5;156m$HEADVER\e[0m to current folder..."
cp -r $WEBSRC $SRCPATCH/webgui_gen2_$HEADVER
echo ""

if [ -d $WEBPATCH ]; then
    cd $WEBPATCH
    echo "Remove old and copy new one..."
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
    #cp -r $SRCPATCH/webgui_gen2_$HEADVER/css/ $SRCPATCH/webgui_gen2_$HEADVER/js/ $SRCPATCH/webgui_gen2_$HEADVER/page/ $SRCPATCH/webgui_gen2_$HEADVER/images/ $WEBPATCH/
    cp -r $SRCPATCH/webgui_gen2_$HEADVER/* $WEBPATCH/
    echo ""
    printf "\e[38;5;156m"
    echo " [ Web Source already update to HEAD!!! ]"
    printf "\e[0m"
    echo ""
else
    printf "\e[38;5;203m"
    echo "[$WEBPATCH] incorrect"
    printf "\e[0m"
    exit
fi
