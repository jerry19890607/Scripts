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

IP=10.138.160.30
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
XML_INFO="GET_SSDP_INFO.XML"
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi
OP_XML_INFO="config_ssdp"
#TEST_URL=$HTTPS_IP/$REDFISH_PATH/v1/a.cgi 
DATA="op=config_ssdp&SSDP_SERVICE=$1&SSDP_PORT=1901&SSDP_IntervalSec=600&SSDP_TTL=2&SSDP_IPv6Scope=Link"
#login
COOKIE=`curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k 2>/dev/null | grep "$FILTER_COOKIE" | tail -n 1 | awk -F';' '{ split($1,a," "); printf a[2] }'`
if [ ! -z "$COOKIE" ]; then
    ret=`curl -X POST "$IPMI_URL" --cookie "$COOKIE" -i -d "op=$XML_INFO" -k $DEBUG 2>/dev/null`
    echo $ret
    #ret=`echo $ret | sed -n "s|\(<.*Enable=\"\)\(\"\)|\1|p"`
    #echo $ret
    curl -X POST "$OP_URL" --cookie "$COOKIE" -i -d "$DATA" -k $DEBUG
else
    echo "Login fail"
fi
