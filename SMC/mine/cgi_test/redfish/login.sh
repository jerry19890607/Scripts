#!/bin/bash
source parser_args.sh

HTTPS_IP="https://$IP"
CGI_PATH="redfish/v1/SessionService/Sessions"
LOGIN_URL=$HTTPS_IP/$CGI_PATH/

FILTER_COOKIE="Set-Cookie"
EXPECT_HEADER="Expect:"
USERINFO="{\"UserName\":\"$USER\", \"Password\":\"$PWD\"}"

#login
SESSION_URL=`curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k 2>/dev/null`
if [ ! -z "$SESSION_URL" ]; then
    echo $SESSION_URL > test.txt
    #curl -X GET "$HTTPS_IP/$SESSION_URL" -i -k 2>/dev/null | tail -n 1 | jq '.'
    exit 0
else
    echo "Login fail"
    exit 1
fi
