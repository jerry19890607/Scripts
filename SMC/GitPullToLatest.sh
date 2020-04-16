#/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       . Navigate to codebase (ex: /home/jerry/ssd/codebase/verify_uac_compress/x11)
#       . gitPullToLatest.sh

if [ $(pwd | grep codebase) ] && [ $(pwd | grep -i x11) ] || [ $(pwd | grep -i x10) ] || [ $(pwd | grep -i x12) ]; then
    CODEBASES_PATH=$(pwd)
    echo "[ Codebase path: $CODEBASES_PATH ]"
    echo ""
else
    echo "You're in the worng path, please Navigate to codebase path (ex: /home/jerry/ssd/codebase/verify_uac_compress/x11)"
    echo "exit..."
    exit
fi

COMMAND="sshpass -p smcipmi0716 git pull"
REBASE="git rebase"

echo ""
echo " [GOTO BASE]"
echo " [PULL BASE]"
$COMMAND &&
$REBASE
echo " [PULL BASE Finished]"
cd $CODEBASES_PATH/redfish/
echo ""
echo " [GOTO redfish]"
echo " [PULL redfish]"
$COMMAND &&
$REBASE
echo " [PULL redfish Finished]"

if [[ $(pwd | grep -i x11) || $(pwd | grep -i x10) ]];
then
    cd $CODEBASES_PATH/hii/
    echo ""
    echo " [GOTO hii]"
    echo " [PULL hii]"
    $COMMAND
    $REBASE
    echo " [PULL hii Finished]"
    cd $CODEBASES_PATH/noVNC/
    echo ""
    echo " [GOTO noVNC]"
    echo " [PULL noVNC]"
    $COMMAND &&
    $REBASE
    echo " [PULL noVNC Finished]"
fi

echo ""
echo " [Git update to lstest finished!!]"
echo ""
