#!/usr/bin/env bash

STM32_IMG="stm32:main"
USB_PATH="$(lsusb | grep ST-LINK | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':')"

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${STM32_IMG}"; then
  docker build -t "${STM32_IMG}" .
fi

set -x
#docker run --rm -it --device="${USB_PATH}" --privileged --cap-add SYS_ADMIN "${@}" stm32:main /bin/bash
docker run --rm -it --device="${USB_PATH}" "${STM32_IMG}" "${@}" /bin/bash
