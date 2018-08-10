#!/bin/sh

SRC_FILE=${1:-main.c}
TARGET_ARCH=${2:-attiny2313}

if [ -f "$SRC_FILE" ]
then
  echo -n "Building $SRC_FILE for AVR ($TARGET_ARCH): "
  echo -n "compile..."
  avr-gcc -Wall -g -Os -mmcu=$TARGET_ARCH -o "`basename $SRC_FILE .c`.bin" "$SRC_FILE"
  echo -n "link..."
  avr-objcopy -j .text -j .data -O ihex "`basename $SRC_FILE .c`.bin" "`basename $SRC_FILE .c`.hex"
  echo "done."
else
  echo "Could not find C file: $SRC_FILE"
fi
