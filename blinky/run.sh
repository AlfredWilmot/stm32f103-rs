#!/usr/bin/env bash

set -e

PROJ=blinky
TOOLCHAIN=thumbv7m-none-eabi
BIN="${PROJ}.bin"
ELF_PATH="target/${TOOLCHAIN}/debug/${PROJ}"

cargo build
arm-none-eabi-objcopy -O binary "${ELF_PATH}" "${BIN}"
st-flash write "${BIN}" 0x08000000
