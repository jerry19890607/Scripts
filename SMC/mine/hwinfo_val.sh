#!/bin/bash

HWINFO=$1
MASK=$2
OFFSET=$3

printf "0x%02x\n", $(((HWINFO & MASK) >> OFFSET))
