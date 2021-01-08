#!/bin/bash
CONF=config
[ ! -f $CONF ] && echo ".config don't exist" && exit 1
. $CONF

while getopts "s:u:p:" opt
do
    case $opt in
        "s")
            IP=$OPTARG
            ;;
        "u")
            USER=$OPTARG
            ;;
        "p")
            PASSWD=$OPTARG
            ;;
    esac
done

#ping ${IP} -c 1 -W 2
#if [ $? -ne 0 ];then
#    echo "${IP} not found"
#    exit 1
#fi

RAW="raw"
IPMI="${TOOL} -H ${IP} -U ${USER} -P ${PASSWD}"

function comm_getValueByIndex
{
    str=$1
    num=$2
    field="-f$((num+1))"
    echo $str | cut -d' ' $field
}

function comm_getValueByRange
{
    str=$1
    start=$2
    len=$3
    end=$((start + len))

    idx=0
    ret=""
    for val in $str
    do
        if [ $idx -ge  $start ]; then
            ret="${ret} ${val}"
        fi
        idx=$((idx+1))

        if [ $idx -gt $end ]; then
            break;
        fi
    done

    echo $ret
}

function comm_toString
{
    str=$1
    idx=0
    ret=""
    for val in $str
    do
        char=`echo 0x${val} | xxd -r`
        ret=${ret}${char}
        if [ -z $char ]; then
            break;
        fi
        idx=$((idx+1))
    done

    echo $ret
}

function pingServer
{
    SEC=$1
    SEC=${SEC:=1}
    ping ${IP} -c 1 -W ${SEC} > /dev/null
    echo $?
}
