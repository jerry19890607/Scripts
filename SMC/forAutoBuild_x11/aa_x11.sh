#!/bin/sh

echo "Start build x11 codebase..."
echo ""
echo  -e "\e[38;5;120mStart build x11 codebase...\e[0m"
echo ""

cacheclean.sh
make rf ver=1.0.0 core=8 dg=y
