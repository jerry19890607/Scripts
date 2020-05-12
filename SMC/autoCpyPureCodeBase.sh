#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#		. cpyCodebase.sh $CODEBASE

CODEBASE=$1
DES=$(pwd)
PURE_PATH=/home/jerry/codebase/Pure
CODE_PATH=/home/jerry/codebase
FOLDER=$(date +%Y_%j)

cd $CODE_PATH &&
mkdir $FOLDER &&
cd $PURE_PATH/$FOLDER &&

