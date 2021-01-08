#!/bin/bash
source parser_args.sh

LOGIN=./login.sh
FAIL=""

hostname=$1

HTTPS_IP="https://$IP"
CGI_PATH=cgi
IPMI_URL=$HTTPS_IP/$CGI_PATH/xml_dispatcher.cgi
WWW_URL=$HTTPS_IP/$CGI_PATH/url_redirect.cgi
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi

debug_file=log.txt
echo "" > $debug_file

COOKIE=`${LOGIN} $@`
if [ $? -eq 0 ]; then
    #echo $IPMI_URL
    #echo $COOKIE
    QSTRING="url_name=config_bmc_webSession"
    ret=`curl -X POST "$WWW_URL" -d "$QSTRING" --cookie "$COOKIE" -i -k 2>/dev/null | grep "CSRF_TOKEN"`
    ret=`echo $ret | sed -n "s|\(^.*CSRF_TOKEN\", \"\)\(.*\)\(\".*\)|\2|p"`
    CSRF="CSRF_TOKEN: $ret"
    #echo "$CSRF"
    #echo ""
    
    #QSTRING="op=Get_PlatformInfo.XML&r=(0,0)"
    #QSTRING="op=CONFIG_INFO.XML&r=(0%2C0)"
    #curl -X POST "$IPMI_URL" -d "$QSTRING" --cookie "$COOKIE" -H "$CSRF" -i -k 2>/dev/null

    QSTRING="op=config_lan&bmcip=10.148.160.115&bmcmask=255.255.0.0&gatewayip=10.148.0.250&en_dhcp=on&en_vlan=off&vlanID=&dns_server=10.135.0.253&bmcipv6_dns_server=&bmcipv6_addr=&bmcipv6_autoconf=on&dhcpv6_mode=stateless&lan_interface=2&link_conf=0&ip_protocol_status=1&hostname=$hostname&rt_src=0&rt_del=0&rt_idx=0&srt_router0=&srt_pval0=&srt_plen0="
    curl -X POST "$OP_URL" -d "$QSTRING" --cookie "$COOKIE" -H "$CSRF" -i -k 2>/dev/null
fi
