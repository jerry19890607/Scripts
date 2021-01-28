#!/bin/sh

echo "Start build x12 codebase..."

export SMCIUSR=tonyhuang
export SMCIPWD=tH09212020

cacheclean.sh &&
make sh12_rot_64_rsa4k_std ver=9.00.1 core=8 &&
make sh12_rot_64_rsa4k_std signfile=./images/AST2500_all.bin
