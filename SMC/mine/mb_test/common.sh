#!/bin/bash
CONF=.config
[ ! -f $CONF ] && echo ".config don't exist" && exit 1
. $CONF

while getopts "hs:u:p:" opt
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
        "h")
            echo "-s: Target IP"
            echo "-u: username"
            echo "-p: password"
            exit 1
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
    for c in $str
    do
        if [ $idx -ge  $start ]; then
            ret="${ret} ${c}"
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
    ret=""
    for t in $str
    do
        val=`printf "%d" 0x${t}`
        #echo "$val ($t)"
        if [[ $val -lt 0x20 ]] || [[ $val -gt 0x7e ]];then
            c=20
        else
            c=$t
        fi
        #echo $c
        char=`echo 0x${c} | xxd -r`
        ret=${ret}${char}
        if [ -z "$char" ]; then
            continue;
        fi
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
