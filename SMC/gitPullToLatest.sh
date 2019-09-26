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

echo ""
echo " [GOTO X11]"
echo ""
echo " [PULL X11]"
echo ""
$COMMAND &&
cd noVNC/
echo ""
echo " [GOTO noVNC]"
echo ""
echo " [PULL noVNC]"
echo ""
$COMMAND &&
cd ../redfish/
echo ""
echo " [GOTO redfish]"
echo ""
echo " [PULL redfish]"
echo ""
$COMMAND &&
cd ../hii/
echo ""
echo " [GOTO hii]"
echo ""
echo " [PULL hii]"
echo ""
$COMMAND
echo ""
echo " [All Finished!!]"
