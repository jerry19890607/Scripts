#!/bin/sh

echo ""
echo  -e "\e[38;5;120mStart AST2500 x12 build...\e[0m"
echo ""

export SMCIUSR=austinl
export SMCIPWD=@Super99

cacheclean.sh &&
# old target
#make sh12_rot_64_rsa4k_std ver=1.0.0 core=8 &&
#make sh12_rot_64_rsa4k_std signfile=./images/AST2500_all.bin

# new target
make sh12_rot_ast25_std_p ver=1.0.0 core=8 &&
make sh12_rot_ast25_std_p signfile=./images/AST2500_all.bin

isbmc2k4k signtmp/signed_*.bin

#Sign cpld firmware
#make signcpld file=<SOMEWHERE>/my.jed
#ls -l signtmp/signcpld/prod_signed_cpld.bin
#ls -l signtmp/signcpld/debug_signed_cpld.bin
