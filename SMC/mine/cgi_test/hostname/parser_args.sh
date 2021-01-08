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

IP=10.148.160.115
USER=ADMIN
PWD=ADMIN

while getopts "c:s:u:p:hd" opt
do
    case $opt in
        "c")
            cmd=$OPTARG
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
