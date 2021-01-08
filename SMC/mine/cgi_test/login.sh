#!/bin/bash
source parser_args.sh

HTTPS_IP="https://$IP"
CGI_PATH=cgi
LOGIN_URL=$HTTPS_IP/$CGI_PATH/login.cgi

FILTER_COOKIE="Set-Cookie: SID"
EXPECT_HEADER="Expect:"
USERINFO="name=$USER&pwd=$PWD"

#login
echo curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k
COOKIE=`curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k 2>/dev/null | grep "$FILTER_COOKIE" | tail -n 1 | awk -F';' '{ split($1,a," "); printf a[2] }'`
if [ ! -z "$COOKIE" ]; then
    echo $COOKIE
    exit 0
else
    echo "Login fail"
    exit 1
fi
