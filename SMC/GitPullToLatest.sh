#/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       . Navigate to codebase (ex: /home/jerry/ssd/codebase/verify_uac_compress/x11)
#       . gitPullToLatest.sh

if [ $(pwd | grep codebase) ] && [ $(pwd | grep x11) ] || [ $(pwd | grep x10) || [ $(pwd | grep x12) ]; then
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
echo " [GOTO X11]"
echo " [PULL X11]"
$COMMAND &&
$REBASE
echo " [PULL X11 Finished]"
cd noVNC/
echo ""
echo " [GOTO noVNC]"
echo " [PULL noVNC]"
$COMMAND &&
$REBASE
echo " [PULL noVNC Finished]"
cd ../redfish/
echo ""
echo " [GOTO redfish]"
echo " [PULL redfish]"
$COMMAND &&
$REBASE
echo " [PULL redfish Finished]"
cd ../hii/
echo ""
echo " [GOTO hii]"
echo " [PULL hii]"
$COMMAND
$REBASE
echo " [PULL hii Finished]"
echo ""
echo " [All Finished!!]"
