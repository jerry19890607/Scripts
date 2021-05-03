#/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       . Navigate to codebase (ex: /home/jerry/ssd/codebase/verify_uac_compress/x11)
#       . gitPullToLatest.sh

NOW=$(pwd)
if [ ! -z "$(cat .git/config| grep x12)" ]; then
    CODEBASE=x12
elif [ ! -z "$(cat .git/config| grep x11)" ]; then
    CODEBASE=x11
elif [ ! -z "$(cat .git/config| grep x10)" ]; then
    CODEBASE=x10
else
    echo "Unrecognizable codebase! Exit..."
    exit
fi

<<'###BLOCK-COMMENT'
if [ ! -z "$(git branch | grep "\* master")" ]; then
    :
else
    echo "Not under Master! Exit..."
    exit
fi
###BLOCK-COMMENT

COMMAND="sshpass -p smcipmi0716 git pull"
REBASE="git rebase"

echo -e " \e[33m[PULL $CODEBASE...]\e[0m"
$COMMAND &&
$REBASE
echo -e " \e[33m[PULL $CODEBASE Finished]\e[0m"

if [ $CODEBASE == "x11" ] || [ $CODEBASE == "x10" ];
then
    echo ""
    cd $NOW/redfish
    echo -e " \e[33m[PULL redfish...]\e[0m"
    $COMMAND && $REBASE
    echo -e " \e[33m[PULL redfish Finished]\e[0m"

    echo ""
    cd $NOW/hii
    echo -e " \e[33m[PULL hii...]\e[0m"
    $COMMAND
    $REBASE
    echo -e " \e[33m[PULL hii Finished]\e[0m"

    echo ""
    cd $NOW/noVNC
    echo -e " \e[33m[PULL noVNC...]\e[0m"
    $COMMAND &&
    $REBASE
    echo -e " \e[33m[PULL noVNC Finished]\e[0m"
fi

echo ""
echo -e " \e[38;5;47m[Git update to lstest finished!!!]\e[0m"
echo ""
