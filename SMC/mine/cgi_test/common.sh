#!/bin/bash
source parser_args.sh
LOGIN=./login.sh

HTTPS_IP="https://$IP"
CGI_PATH=cgi
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi

COOKIE=`${LOGIN} $@`
if [ $? -eq 0 ]; then
    case $cmd in
        "alerts")
            ;;
        "datetime")
            ;;
        "ladp")
            ;;
        "ladp")
            ;;
        "ad")
            source ad.src
            ;;
        "radius")
            ;;
        "mouse")
            ;;
        "network")
            ;;
        "ddns")
            ;;
        "smtp")
            ;;
        "ssl")
            ;;
        "user")
            ;;
        "port")
            ;;
        "ipctrl")
            ;;
        "snmp")
            ;;
        "fan")
            ;;
        "session")
            ;;
        "syslog")
            ;;
        "kcs")
            ;;
        "ssdp")
            ;;
        "floppy")
            ;;
        "cd")
            ;;
    esac

    curl -X POST "$OP_URL" -d "$QSTRING" --cookie "$COOKIE" -i -k $DEBUG #2>/dev/null
else
    echo fail
fi
