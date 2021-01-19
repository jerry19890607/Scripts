#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       . cloneSMC.sh $CODEBASE [$BRANCH]
#       . cloneSMC.sh x10
#       . cloneSMC.sh x11 REL_X11AST2500_171_2_20190715

CODEBASE=$1
BRANCH=$2
GIT_REPOSITORY="ssh://jerryshih@10.138.34.2/var/git"
COMMAND="sshpass -p smcipmi0716 git clone"

function switchBrnch()
{
    git co $BRANCH && echo " [Jerry] Change branch to \"$BRANCH\"" || echo " [Jerry] change branch to $BRANCH FAIL!!!"
}

echo " [Jerry] Clone $CODEBASE start"
$COMMAND $GIT_REPOSITORY/$CODEBASE.git
if [ "$?" -ne "0" ];
then
    echo " [Jerry] Clone \"$X\" FAIL!!!"
    exit 1
else
    echo " [Jerry] Clone \"$X\" OK"
    echo ""
    echo " [Jerry] GOTO $CODEBASE"
    cd $CODEBASE
fi

if [ -n "$BRANCH" ]; then switchBrnch; fi

if [ "$CODEBASE" != "x12" ]; then
    echo ""
    echo " [Jerry] Clone noVNC start"
    $COMMAND $GIT_REPOSITORY/noVNC.git && echo " [Jerry] Clone \"noVNC\" OK"  || echo " [Jerry] Clone \"noVNC\" FAIL!!!"

    if [ -n "$BRANCH" ]; then
        echo " [Jerry] GOTO noVNC"
        cd noVNC
        switchBrnch
        cd ../
    fi

    echo ""
    echo " [Jerry] Clone redfish start"
    $COMMAND $GIT_REPOSITORY/redfish.git && echo " [Jerry] Clone \"redfish\" OK"  || echo " [Jerry] Clone \"redfish\" FAIL!!!"
    if [ -n "$BRANCH" ]; then
        echo " [Jerry] GOTO redfish"
        cd redfish
        switchBrnch
        cd ../
    fi

    if [ $CODEBASE == "x11" ];
    then
        cd $CODEBASE/redfish
        git co redfish_X11_2500
        cd $CODEBASE
    else

    if [ "$CODEBASE" != "x10" ]
    then
        echo ""
        echo " [Jerry] Clone hii start"
        $COMMAND $GIT_REPOSITORY/hii.git && echo " [Jerry] Clone \"hii\" OK"  || echo " [Jerry] Clone \"hii\" FAIL!!!"
        if [ -n "$BRANCH" ]; then
            echo " [Jerry] GOTO hii"
            cd hii
            switchBrnch
            cd ../
        fi
    else
        echo " [Jerry] Ignore \"hii\""
    fi
fi
