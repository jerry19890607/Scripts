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

IP=10.138.161.32
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
IPMI_URL=$HTTPS_IP/$CGI_PATH/ipmi.cgi
OP_URL=$HTTPS_IP/$CGI_PATH/op.cgi
TEST_URL=$HTTPS_IP/$REDFISH_PATH/v1/a.cgi 

case $TEST_CASE in
    "bmc")
        [ -z "$FILE" ] || [ ! -f "$FILE" ] && echo "$FILE error" && exit 1

        UPLOAD_URL=$HTTPS_IP/$CGI_PATH/oem_firmware_upload.cgi
        IMG_TAG="fw_image=@$FILE"
        ;;
    "bios")
        [ -z "$FILE" ] || [ ! -f "$FILE" ] && echo "$FILE error" && exit 1

        UPLOAD_URL=$HTTPS_IP/$CGI_PATH/bios_upload.cgi
        IMG_TAG="bios_rom=@$FILE"
        ;;
    "ssl")
        UPLOAD_URL=$HTTPS_IP/$CGI_PATH/upload_ssl.cgi
        FILE_1=`echo $FILE | awk -F',' '{ printf $1 }'`
        FILE_2=`echo $FILE | awk -F',' '{ printf $2 }'`

        [ -z "$FILE_1" ] || [ ! -f "$FILE_1" ] && echo "$FILE_1 error" && exit 1
        [ -z "$FILE_2" ] || [ ! -f "$FILE_2" ] && echo "$FILE_2 error" && exit 1

        IMG_TAG="cert_file=@$FILE_1 -F key_file=@$FILE_2"
        ;;
    *)
        usage;
        exit 1
        ;;
esac

COOKIE=`curl -X POST "$LOGIN_URL" -i -d "$USERINFO" -k 2>/dev/null | grep "$FILTER_COOKIE" | tail -n 1 | awk -F';' '{ split($1,a," "); printf a[2] }'`
if [ ! -z "$COOKIE" ]; then
    #curl -X POST "$IPMI_URL" --cookie "$COOKIE" -i -d "op=GET_SYSLOCKDOWN_CONF.XML" -k $DEBUG
    #curl -X GET "$TEST_URL" --cookie "$COOKIE" -k $DEBUG

    curl -X POST "$UPLOAD_URL" -H "$EXPECT_HEADER" --cookie "$COOKIE" -F $IMG_TAG -k $DEBUG
else
    echo "Login fail"
fi
