#!/bin/bash
usage()
{
    echo "usage $0 -s [ip addr] -u [username] -p [password] -f [uploadfile]"
    echo "    -b: BIOS upload"
    echo "    -s: IP address"
    echo "    -u: Login useranme"
    echo "    -p: Login passowrd"
    echo "    -h: help"
}

IP=10.138.160.81
USER=ADMIN
PWD=ADMIN
FILE=
ISBIOS=0

while getopts "s:u:p:hdb" opt
do
    case $opt in
        "b")
            ISBIOS=1
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
IPMI_URL=$HTTPS_IP/$CGI_PATH/ipmi.cgi
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi
TEST_URL=$HTTPS_IP/$REDFISH_PATH/v1/a.cgi 

if [ $ISBIOS -eq 0 ];then
    UPGRADE_OPT="op=main_fwupdate&preserve_config=1&preserve_sdr=1&preserve_ssl=1" #&timeStamp
else
    #UPLOAD_URL=$HTTPS_IP/$CGI_PATH/bios_upload.cgi
    exit 1
fi

COOKIE=`curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k 2>/dev/null | grep "$FILTER_COOKIE" | tail -n 1 | awk -F';' '{ split($1,a," "); printf a[2] }'`
if [ ! -z "$COOKIE" ]; then
    #curl -X POST "$IPMI_URL" --cookie "$COOKIE" -i -d "op=GET_SYSLOCKDOWN_CONF.XML" -k $DEBUG
    curl -X POST "$OP_URL" --cookie "$COOKIE" -i -d "$UPGRADE_OPT" -k $DEBUG
    #curl -X GET "$TEST_URL" --cookie "$COOKIE" -k $DEBUG
else
    echo "Login fail"
fi
