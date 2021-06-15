#!/bin/sh

echo ""
echo  -e "\e[38;5;120mStart AST2600 x12 build...\e[0m"
echo ""

PRODUC_KEY=0

export SMCIUSR=austinl
export SMCIPWD=@Super99

if [ $PRODUC_KEY -ne 1 ]; then
    echo  -e "\e[38;5;120mDebug key build\e[0m"
    echo ""
    make sx12_rot_ast26_d core=32 ver=1.0.0
    make sx12_rot_ast26_d signfile=./images/AST2600_all.bin
fi

if [ $PRODUC_KEY -eq 1 ]; then
    echo  -e "\e[38;5;120mProduct key build\e[0m"
    echo ""
    make sx12_rot_ast26_p core=32 ver=1.0.0
    make sx12_rot_ast26_p signfile=./images/AST2600_all.bin
fi

isbmc2k4k signtmp/signed_*.bin

#Sign cpld firmware
#make signcpld file=<SOMEWHERE>/my.jed
#ls -l signtmp/signcpld/prod_signed_cpld.bin
#ls -l signtmp/signcpld/debug_signed_cpld.bin
