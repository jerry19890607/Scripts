#!/bin/sh

echo "Start build x12 codebase..."

export SMCIUSR=tonyhuang
export SMCIPWD=Th20201215

cacheclean.sh &&
make sh12_rot_64_rsa4k_std ver=1.0.0 core=8 &&
make sh12_rot_64_rsa4k_std signfile=./images/AST2500_all.bin
