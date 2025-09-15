#!/usr/bin/env bash

PROJ=blinky
TOOLCHAIN=thumbv7m-none-eabi
GDB_SCRIPT="openocd.gbd"

gdb-multiarch -x "${GDB_SCRIPT}" "target/${TOOLCHAIN}/debug/${PROJ}"
