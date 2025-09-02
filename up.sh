#!/usr/bin/env bash

# Setup and enter a docker container that has access to a connected STLINK

STM32_IMG="stm32:main"
USB_PATH="$(lsusb | grep ST-LINK | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':'| sed -n '1p')"

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${STM32_IMG}"; then
  docker build -t "${STM32_IMG}" .
fi

#CMD="docker run --rm -it ${*}"
CMD="docker run --rm -it --privileged --cap-add SYS_ADMIN ${*}"
if [ -n "${USB_PATH}" ]; then
  CMD+=" --device=${USB_PATH} --env USB_PATH=${USB_PATH}"
fi

CMD+=" ${STM32_IMG} /bin/bash"

echo "${CMD}"
eval "${CMD}"
