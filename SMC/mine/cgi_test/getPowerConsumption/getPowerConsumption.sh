#!/bin/bash
source parser_args.sh
LOGIN=./login.sh

HTTPS_IP="https://$IP"
CGI_PATH=cgi
IPMI_URL="$HTTPS_IP/$CGI_PATH/ipmi.cgi"
QSTRING="op=POWER_CONSUMPTION.XML"
METHOD=POST

COOKIE=`${LOGIN} $@`
if [ $? -eq 0 ]; then
    echo "curl -X $METHOD "$IPMI_URL" -d "$QSTRING" --cookie "$COOKIE" -i -k $DEBUG"
    ret=`curl -X $METHOD "$IPMI_URL" -d "$QSTRING" --cookie "$COOKIE" -i -k $DEBUG 2>/dev/null | python -m xml`
    #data=`echo $ret | grep -oP '(?<=<MONTH>)'`

    echo $ret
    
    #emails=($(grep -oP '(?<=email>)[^<]+' "/my_path/spam.xml"))
else
    echo "login fail"
fi
