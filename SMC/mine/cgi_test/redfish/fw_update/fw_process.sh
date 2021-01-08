#!/bin/bash
. config

DOMAIN="https://$IP"
percent=0
TASK_PATH=$1
URL=${DOMAIN}${TASK_PATH}
echo $URL
#echo $URL
#echo curl $M_GET $URL --user $USER:$PASSWD -k
#ret=`curl $M_GET $URL --user $USER:$PASSWD -k  2>/dev/null | jq '.PercentComplete | tonumber'`
#echo $ret
#exit 1
while [ 1 ]
do
    percent=`curl $M_GET $URL --user $USER:$PASSWD -k 2>/dev/null | jq '.PercentComplete | tonumber'`
    if [ $? -ne 0 ]; then
        break;
    fi
    printf "%3d%%\r" $percent

    if [[ $percent == 100 ]]; then
        echo ""
        echo "Finish"
        break;
    fi
    sleep 1
done
