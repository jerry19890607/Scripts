#!/bin/bash
source parser_args.sh

function percent_process
{
    curIdx=$1
    maxIdx=$2
    str=""

    percent=$((curIdx * 100 / maxIdx))
    num=$((percent / 5))
    for (( i = 0; i < $num; i++ )); do
        str=$str"="
    done

    printf "[%-20s]%3d%%\r" "$str" "$percent"
}

LOGIN=./login.sh
FAIL=""

HTTPS_IP="https://$IP"
CGI_PATH=cgi
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi
IPMI_URL=$HTTPS_IP/$CGI_PATH/ipmi.cgi

debug_file=log.txt
echo "" > $debug_file

COOKIE=`${LOGIN} $@`
if [ $? -eq 0 ]; then
    ret=`curl -X POST "$IPMI_URL" -d "$QSTRING" --cookie "$COOKIE" -i -k $DEBUG  2>/dev/null`


    files=`find -name "*.src"`
    fileSize=`find -name "*.src" | wc -l`
    cnt=0
    fcnt=0
    for file in $files
    do
        URL=""
        CGI_NAME=""
        UPLOAD_FILE=""
        QSTRING=""
        EXPECT_HEADER=""

        source $file

        if [ -z "$CGI_NAME" ]; then
            URL=$OP_URL
        else
            URL=$HTTPS_IP/$CGI_PATH/$CGI_NAME
        fi

        if [ -z "$UPLOAD_FILE" ]; then
            if [ -z "$QSTRING" ];then
                QSTRING="-d \"\""
            else
                QSTRING="-d $QSTRING"
            fi
        else
            QSTRING="$UPLOAD_FILE"
        fi

        ret=`curl -X POST $URL $QSTRING $EXPECT_HEADER --cookie "$COOKIE" -i -k $DEBUG 2>/dev/null`
        stat=$?
        ret2=`echo $ret | grep "SysLockdown is enabled"`
        if [ $stat -ne 0 ] || [ -z "$ret2" ]; then
            FAIL="${FAIL}, $file"
            fcnt=$((fcnt + 1))
        fi

        echo "=====$cnt: $file=====" >> $debug_file
        echo "curl -X POST $URL $QSTRING $EXPECT_HEADER --cookie "$COOKIE" -i -k $DEBUG" >> $debug_file
        echo "$ret" >> $debug_file
        echo "@@@@@$cnt: $file@@@@@" >> $debug_file

        cnt=$((cnt + 1))
        percent_process $cnt $fileSize
        sleep 0.5
    done
else
    echo "login fail"
    exit 0
fi

echo ""
if [ ! -z "$FAIL" ];then
    echo "fail numbers: $fcnt ... [$FAIL]"
else
    echo "All done"
fi
