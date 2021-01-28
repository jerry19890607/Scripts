#!/bin/sh

echo "Start AST2600 x12 build..."

PRODUC_KEY=0

export SMCIUSR=tonyhuang
export SMCIPWD=Th20201215

if [ $PRODUC_KEY -ne 1 ]; then
    echo 'Debug key build'
    make sx12_rot_ast26_d core=32 ver=1.0.0
    make sx12_rot_ast26_d signfile=./images/AST2600_all.bin
fi

if [ $PRODUC_KEY -eq 1 ]; then
    echo 'Product key build'
    make sx12_rot_ast26_p core=32 ver=1.0.0
    make sx12_rot_ast26_p signfile=./images/AST2600_all.bin
fi

isbmc2k4k signtmp/signed_AST2600_4675.bin

#Sign cpld firmware
#make signcpld file=<SOMEWHERE>/my.jed
#ls -l signtmp/signcpld/prod_signed_cpld.bin
#ls -l signtmp/signcpld/debug_signed_cpld.bin
