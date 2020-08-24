#!/bin/sh
dd if=/dev/zero of=./fortestfile bs=1M count=20 && rm ./fortestfile
