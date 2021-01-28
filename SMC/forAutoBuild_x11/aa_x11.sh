#!/bin/sh

echo "Start build x11 codebase..."

cacheclean.sh
make rf ver=1.9.0 core=8 dg=y
