#!/bin/bash
usage()
{
    echo "usage $0 -s [ip addr] -u [username] -p [password] -f [uploadfile1,uploadfile2,...]"
    echo "    -s: IP address"
    echo "    -u: Login useranme"
    echo "    -p: Login passowrd"
    echo "    -f: Upload file to update"
    echo "    -t: Test case: bmc, bios, ssl"
    echo "    -h: help"
}

IP=10.138.160.135
USER=ADMIN
PWD=ADMIN
FILE=

while getopts "t:s:u:p:f:hd" opt
do
    case $opt in
        "t")
            TEST_CASE=$OPTARG
            ;;
        "s")
            IP=$OPTARG
            ;;
        "u")
            USER=$OPTARG
            ;;
        "p")
            PWD=$OPTARG
            ;;
        "f")
            FILE=$OPTARG
            ;;
        "d")
            DEBUG="--trace-ascii debug.txt"
            ;;
        "h" | *)
            usage
            exit 0
            ;;
    esac
done

HTTPS_IP="https://$IP"
CGI_PATH=cgi
REDFISH_PATH=redfish

FILTER_COOKIE="Set-Cookie"
EXPECT_HEADER="Expect:"
USERINFO="name=$USER&pwd=$PWD"

LOGIN_URL=$HTTPS_IP/$CGI_PATH/login.cgi
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi
QSTRING="op=mount_iso&tagid=$1"
echo "QSTR:$QSTRING"

COOKIE=`curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k 2>/dev/null | grep "$FILTER_COOKIE" | tail -n 1 | awk -F';' '{ split($1,a," "); printf a[2] }'`
if [ ! -z "$COOKIE" ]; then
    echo "Login OK"
    curl -X POST "$OP_URL" -d "$QSTRING" --cookie "$COOKIE" -k $DEBUG
    echo ""
else
    echo "Login fail"
fi
