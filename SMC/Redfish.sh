CURL=/usr/bin/curl
PY=/usr/bin/python

TOOLNAME=$0
IP=$1
shift
ARGUNUM=$#
COMMAND=$1
OPTION=$2

usage () {
    echo -e "Usage:"
    echo -e " Redfish.sh IP_ADDR [Options]"
    echo -e ""
    echo -e "Options:"
    echo -e "-m"
    echo -e "   [GET | SET | POST | DELETE | PATCH | HEAD | OPTIONS]"
    echo -e "   Defautl: GET"
    echo -e "-a"
    echo -e "   UserNmae:PWD"
    echo -e "   Defautl: ADMIN:ADMIN"
    echo -e "-p "
    echo -e "   Ex: Systems/1"
    echo -e "   Defautl: /redfish/v1/"
    echo -e ""
}

function valid_ip()
{
    echo "valid_ip function"
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [ -z $IP ]; then
    echo -e "\e[7;49;31mERROR: No IP address!!\e[0m"
    echo ""
    usage
    exit
fi

# Verify IP format
valid_ip $IP
if [[ $? -eq 1 ]]; then
    echo -e "\e[7;49;31mERROR: Invalid IP address!!\e[0m"
    echo ""
    usage
    exit
fi

# Check option not odd
let "NUM=$ARGUNUM % 2"
if [ $NUM -ne 0 ]; then
    echo -e "\e[7;49;31mERROR: Argument incorrect!!\e[0m"
    echo ""
    usage
    exit
fi

setArgument () {
    echo "comand: $COMMAND"
    case $COMMAND in
    -m)
        if [ -z $METHOD ]; then
            eval METHOD=$OPTION
            #echo "METHOD: $METHOD"
        else
            echo "ERROR: Dupicate $COMMAND!!"
            usage
            exit
        fi
    ;;
    -p)
        if [ -z $URL ]; then
            eval URL=$OPTION
            #echo "URL: $URL"
        else
            echo "ERROR: Dupicate $COMMAND!!"
            usage
            exit
        fi
    ;;
    -a)
        if [ -z $AUTH ]; then
            eval AUTH=$OPTION
            #echo "AUTH: $AUTH"
        else
            echo "ERROR: Dupicate $COMMAND!!"
            usage
            exit
        fi
    ;;
    *)
        echo "ERROR: Wrong command!!"
        usage
        exit
    ;;
    esac
}

setCurlCommand () {
    #echo "$CURL -k -X $METHOD -H "Content-Type: application/json" -u $AUTH https://$IP/redfish/v1/$URL | $PY -m json.tool"
    $CURL -k -X $METHOD -H "Content-Type: application/json" -u $AUTH https://$IP/redfish/v1/$URL | $PY -m json.tool
}

while [ $ARGUNUM -ge 2 ]
do
    setArgument
    shift
    shift
    ARGUNUM=$#
    COMMAND=$1
    OPTION=$2
    #echo "After: $ARGUNUM"
    #echo "arg: $METHOD $URL $AUTH"
    #echo ""
done

if [ -z $METHOD ]; then
    eval METHOD="GET"
fi
if [ -z $URL ]; then
    eval URL=""
fi
if [ -z $AUTH ]; then
    eval AUTH="ADMIN:ADMIN"
fi

# Parse response header
while IFS=':' read key value; do
    # trim whitespace in "value"
    value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}

    case "$key" in
        Server) SERVER="$value"
                ;;
        Content-Type) CT="$value"
                ;;
        HTTP*) read PROTO STATUS MSG <<< "$key{$value:+:$value}"
                ;;
     esac
done < <($CURL -I -k -X $METHOD -H "Content-Type: application/json" -u $AUTH https://$IP/redfish/v1/$URL)


if [ -z $STATUS ]; then
    echo -e "\e[7;49;31mERROR: No Respons!!\e[0m"
    echo ""
    exit
fi

# Show response header
if [ $STATUS -ge 200 ] || [ $STATUS -le 299 ]; then
    setCurlCommand
    #echo $SERVER
    echo $CT
    echo -e "\e[7;49;32mRespons: $STATUS\e[0m"
else
    echo -e "\e[7;49;31mRespons: $STATUS\e[0m"
fi

echo ""

