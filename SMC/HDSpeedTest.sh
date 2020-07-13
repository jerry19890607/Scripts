#!/bin/sh
dd if=/dev/zero of=./fortestfile bs=1M count=5 && rm ./fortestfile
